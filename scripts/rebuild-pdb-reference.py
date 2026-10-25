#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["lief==1.0.0"]
# ///
r"""Rebuild a PE's NB10 PDB reference as RSDS using LIEF.

Examples (uv reads the dependency declaration above):
    uv run --no-project scripts/rebuild-pdb-reference.py input.exe -o output.exe
    uv run --no-project scripts/rebuild-pdb-reference.py input.exe -o output.exe \
        --pdb-reference 'C:\symbols\original-name.pdb'

WHY THIS EXISTS
---------------
The original set-vc6-pdb-reference.py helper edits an existing allocation without
moving anything. This experimental companion lets LIEF rebuild the debug data,
usually adding a .debug section. A longer filename/path therefore need not fit
in the old record. It always writes a separate output; it is not wired into the
current build or launch configurations.

There are three separate responsibilities:
  * LIEF parses the PE and builds the new layout.
  * Our compatibility rule converts the legacy PDB identity.
  * CLI policy chooses the embedded PDB reference and destination file.

THE COMPATIBILITY RULE IS STILL SPECIFIC
--------------------------------------
NB10 and RSDS are reference records in the executable, not PDB storage formats:
    NB10: 'NB10', unused DWORD, PDB timestamp DWORD, age DWORD, path + NUL
    RSDS: 'RSDS', 16-byte GUID, age DWORD, UTF-8 path + NUL

The tested DIA/vsdbg readers expose a VC6 PDB 2.00 identity as a GUID with the
timestamp in Data1 and twelve zero bytes. Copy the original age. LIEF identifies
an NB10 record, but its GUID property was zero in our sample: we must read the
timestamp from the raw NB10 bytes instead of copying that property. This does
not open, validate, consolidate, or convert the external PDB. It cannot repair
the /Zi /PDBTYPE:SEPT type-pool limitation or change source paths inside a PDB.

POLICY AND LIMITS
-----------------
By default preserve the original PDB basename, independently of the EXE/output
name. --pdb-reference explicitly sets the embedded reference; it is not a PDB
file to modify or a path-length guarantee from Windows/the debugger. RSDS names
are encoded as UTF-8. Legacy NB10 names have no dependable encoding declaration:
ASCII is the default, --nb10-encoding selects another code page, or an explicit
reference avoids decoding the old name. We do not silently guess a code page.

PE32 and PE32+ layouts are accepted; live legacy-PDB interoperability is verified
on VC6 x86, not every possible producer/architecture. Exactly one CodeView entry
is required; ambiguous multiple references and embedded NB09/NB11 formats fail.
An existing RSDS reference is copied unchanged (reference overrides only apply
to NB10). Signed images and images with COFF symbol tables are outside this
rebuild experiment.

REBUILDING HAS A DIFFERENT PRESERVATION CONTRACT
----------------------------------------------
File length, header space, debug-data placement and overlay offset can change.
Before writing, we reparse the result and require existing section order/RVAs,
virtual sizes, flags and non-debug section bytes to stay intact. Executable
section bytes must be identical, including any padding. Other data directories,
key loader/header properties and other debug-entry payloads must be preserved.
The PE checksum is recomputed. These checks constrain the rebuild; they are not
a proof that every application's self-inspection assumptions remain valid.

The original overlay must survive byte-for-byte, but may move. It may include
the now-unreferenced old NB10 record/path. This is not a path-redaction tool, and
an EOF/offset-dependent application may still need its own runtime test. The CLI
reports overlay movement rather than pretending the file layout was preserved.

All conversion/validation happens before committing output through a temporary
file in the destination directory and os.replace. The input and PDB are never
written; an error leaves an existing destination untouched. Keep the EXE/PDB
identity matched and place the PDB where the emitted reference/search path can
find it; renaming the output EXE does not rename the PDB for you.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
import ntpath
import os
from pathlib import Path
import struct
import sys
import tempfile

import lief


CODEVIEW = lief.PE.Debug.TYPES.CODEVIEW
DEBUG_DIR = lief.PE.DataDirectory.TYPES.DEBUG_DIR
CERTIFICATE = lief.PE.DataDirectory.TYPES.CERTIFICATE_TABLE
EXECUTABLE_SECTION = 0x20000000
HEADER_FIELDS = ("machine", "characteristics", "time_date_stamps", "numberof_symbols", "pointerto_symbol_table")
OPTIONAL_FIELDS = (
    "magic", "imagebase", "addressof_entrypoint", "section_alignment", "file_alignment",
    "subsystem", "dll_characteristics", "major_operating_system_version", "minor_operating_system_version",
    "major_subsystem_version", "minor_subsystem_version", "sizeof_stack_reserve", "sizeof_stack_commit",
    "sizeof_heap_reserve", "sizeof_heap_commit",
)


@dataclass(frozen=True)
class RebuildResult:
    image: bytes
    changed: bool
    pdb_reference: str | None
    overlay_size: int
    original_overlay_offset: int
    rebuilt_overlay_offset: int


def parse_pe(image: bytes):
    """Let LIEF handle the PE layout; retain explicit policy/range validation."""
    if not image.startswith(b"MZ"):
        raise ValueError("Expected a PE image with a DOS MZ header")
    config = lief.PE.ParserConfig()
    # Certificate-bearing images are refused below; decoding their signature
    # contents is unnecessary for the reference conversion.
    config.parse_signature = False
    binary = lief.PE.parse(image, config)
    if binary is None:
        raise ValueError("LIEF could not parse the PE image")
    return binary


def file_bytes(image: bytes, offset: int, size: int, description: str) -> bytes:
    if offset < 0 or size < 0 or offset + size > len(image):
        raise ValueError(f"Invalid file range for {description}")
    return image[offset:offset + size]


def payload(image: bytes, entry) -> bytes:
    # A debug payload can live outside mapped sections. Do not translate its
    # AddressOfRawData as an RVA when PointerToRawData identifies the file bytes.
    return file_bytes(image, entry.pointerto_rawdata, entry.sizeof_data, "debug payload")


def debug_metadata(entry) -> tuple:
    return (entry.type, entry.characteristics, entry.timestamp, entry.major_version, entry.minor_version)


def builder_config(*, debug: bool):
    """Rebuild debug information, not unrelated PE tables that we did not edit."""
    config = lief.PE.Builder.config_t()
    config.debug = debug
    config.imports = False
    config.exports = False
    config.resources = False
    config.relocations = False
    config.tls = False
    config.load_configuration = False
    config.overlay = True
    return config


def verify_rebuild(original: bytes, before, rebuilt: bytes, after, selected: int, expected: bytes) -> None:
    """Reject broader rewrites that could invalidate PDB addresses or runtime data."""
    for name in HEADER_FIELDS:
        if getattr(before.header, name) != getattr(after.header, name):
            raise ValueError(f"Rebuild changed COFF header property {name}")
    for name in OPTIONAL_FIELDS:
        if getattr(before.optional_header, name) != getattr(after.optional_header, name):
            raise ValueError(f"Rebuild changed loader property {name}")

    directories_before = [(d.type, d.rva, d.size) for d in before.data_directories if d.type != DEBUG_DIR]
    directories_after = [(d.type, d.rva, d.size) for d in after.data_directories if d.type != DEBUG_DIR]
    if directories_before != directories_after:
        raise ValueError("Rebuild changed a non-debug data directory")

    # These old file ranges belonged to debug metadata, not application data.
    # A directory inside .rdata may legitimately change as its records move.
    directory = before.debug_dir
    owned = [(before.rva_to_offset(directory.rva), directory.size)]
    owned += [(e.pointerto_rawdata, e.sizeof_data) for e in before.debug if e.sizeof_data]
    if len(after.sections) < len(before.sections):
        raise ValueError("Rebuild removed an existing section")
    for old, new in zip(before.sections, after.sections):
        old_properties = (old.name, old.virtual_address, old.virtual_size, old.characteristics, old.sizeof_raw_data)
        new_properties = (new.name, new.virtual_address, new.virtual_size, new.characteristics, new.sizeof_raw_data)
        if old_properties != new_properties:
            raise ValueError(f"Rebuild moved/reordered/resized an existing section: {old.name}")
        old_data = file_bytes(original, old.pointerto_raw_data, old.sizeof_raw_data, f"section {old.name}")
        new_data = file_bytes(rebuilt, new.pointerto_raw_data, new.sizeof_raw_data, f"rebuilt section {new.name}")
        for index, (a, b) in enumerate(zip(old_data, new_data)):
            if a == b:
                continue
            offset = old.pointerto_raw_data + index
            if old.characteristics & EXECUTABLE_SECTION or not any(start <= offset < start + size for start, size in owned):
                raise ValueError(f"Rebuild changed non-debug bytes in section {old.name}")

    entries_before, entries_after = list(before.debug), list(after.debug)
    if len(entries_before) != len(entries_after):
        raise ValueError("Rebuild changed the number of debug entries")
    # remove_debug/add_debug_info appends the replacement CodeView entry. With
    # exactly one CodeView record, this leaves PDB selection unambiguous and
    # preserves the relative order of every other debug type.
    expected_order = [index for index in range(len(entries_before)) if index != selected] + [selected]
    for index, old_index in enumerate(expected_order):
        old, new = entries_before[old_index], entries_after[index]
        if debug_metadata(old) != debug_metadata(new):
            raise ValueError(f"Rebuild changed debug-entry metadata/order at index {index}")
        wanted = expected if old_index == selected else payload(original, old)
        if payload(rebuilt, new) != wanted:
            raise ValueError(f"Rebuild did not preserve debug payload {index}")
    if bytes(before.overlay) != bytes(after.overlay):
        raise ValueError("Rebuild did not preserve the original overlay contents")
    if after.optional_header.checksum != after.compute_checksum():
        raise ValueError("Rebuilt PE checksum is invalid")


def rebuild_pdb_reference(image: bytes, pdb_reference: str | None = None, nb10_encoding: str | None = None) -> RebuildResult:
    """Rebuild one NB10 reference; preserve its basename unless explicitly overridden."""
    binary = parse_pe(image)
    certificate = binary.data_directory(CERTIFICATE)
    if certificate and (certificate.rva or certificate.size):
        raise ValueError("Signed/certificate-bearing images are not supported; use an unsigned debug image")
    if binary.header.pointerto_symbol_table or binary.header.numberof_symbols:
        raise ValueError("Images with COFF symbol tables are not supported by this rebuild helper")
    entries = list(binary.debug)
    indices = [index for index, entry in enumerate(entries) if entry.type == CODEVIEW]
    if len(indices) != 1:
        raise ValueError(f"Expected exactly one CodeView entry; found {len(indices)}")
    selected = indices[0]
    raw = payload(image, entries[selected])
    overlay_size = len(binary.overlay)
    overlay_offset = binary.overlay_offset
    if raw.startswith(b"RSDS"):
        if pdb_reference is not None:
            raise ValueError("--pdb-reference only applies to NB10 conversion, not an existing RSDS entry")
        return RebuildResult(image, False, None, overlay_size, overlay_offset, overlay_offset)
    if len(raw) < 17 or raw[:4] != b"NB10":
        raise ValueError("Expected an external-PDB NB10 reference (embedded NB09/NB11 are unsupported)")
    end = raw.find(b"\0", 16)
    if end < 0:
        raise ValueError("NB10 PDB path is not null-terminated")
    if pdb_reference is None:
        try:
            name = raw[16:end].decode(nb10_encoding or "ascii")
        except (UnicodeError, LookupError) as error:
            raise ValueError("Cannot decode the NB10 path; specify --nb10-encoding or --pdb-reference") from error
        pdb_reference = ntpath.basename(name)
    if not pdb_reference or "\0" in pdb_reference:
        raise ValueError("Expected a nonempty PDB reference without null bytes")

    timestamp, age = struct.unpack_from("<II", raw, 8)
    guid = struct.pack("<I", timestamp) + bytes(12)
    expected = b"RSDS" + guid + struct.pack("<I", age) + pdb_reference.encode("utf-8") + b"\0"
    replacement = lief.PE.CodeViewPDB(pdb_reference)
    replacement.signature = list(guid)
    replacement.age = age
    old = entries[selected]
    replacement.characteristics = old.characteristics
    replacement.timestamp = old.timestamp  # Directory timestamp is distinct from PDB identity.
    replacement.major_version = old.major_version
    replacement.minor_version = old.minor_version

    # Remove only the selected record. clear_debug() also clears payload bytes
    # for unrelated entries; copying their metadata back does not restore those
    # bytes in LIEF 1.0.0. Keep the other entries and their backing sections live.
    model = parse_pe(image)
    model.remove_debug(list(model.debug)[selected])
    model.add_debug_info(replacement)
    rebuilt = bytes(model.write_to_bytes(builder_config(debug=True)))

    # Compute the checksum from the serialized image, not the pre-build model.
    # The second pass only updates that header field; debug rebuilding is off.
    after = parse_pe(rebuilt)
    after.optional_header.checksum = after.compute_checksum()
    rebuilt = bytes(after.write_to_bytes(builder_config(debug=False)))
    after = parse_pe(rebuilt)
    verify_rebuild(image, binary, rebuilt, after, selected, expected)
    return RebuildResult(rebuilt, True, pdb_reference, overlay_size, overlay_offset, after.overlay_offset)


def convert_file(source: Path, output: Path, pdb_reference: str | None = None,
                 nb10_encoding: str | None = None) -> RebuildResult:
    source, output = source.resolve(), output.resolve()
    if source == output or (output.exists() and os.path.samefile(source, output)):
        raise ValueError("Input and output must be different files")
    result = rebuild_pdb_reference(source.read_bytes(), pdb_reference, nb10_encoding)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=output.parent, prefix=f".{output.name}.", suffix=".tmp", delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(result.image)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, output)
        temporary = None
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Rebuild an unsigned PE's legacy NB10 PDB reference as RSDS using LIEF.")
    parser.add_argument("input", type=Path)
    parser.add_argument("-o", "--output", type=Path, required=True, help="separate destination EXE/DLL")
    parser.add_argument("--pdb-reference", help="embedded UTF-8 PDB filename/path (default: original PDB basename)")
    parser.add_argument("--nb10-encoding", help="explicit encoding for a non-ASCII legacy NB10 path, e.g. cp1250")
    args = parser.parse_args()
    try:
        result = convert_file(args.input, args.output, args.pdb_reference, args.nb10_encoding)
    except (OSError, ValueError, RuntimeError) as error:
        print(f"{parser.prog}: {error}", file=sys.stderr)
        return 1
    print(f"Wrote {args.output} ({len(result.image)} bytes).")
    print(f"NB10 -> RSDS; PDB reference: {result.pdb_reference}" if result.changed else "Already RSDS; copied unchanged.")
    if result.overlay_size:
        print(f"Preserved {result.overlay_size} overlay bytes; offset {result.original_overlay_offset:#x} -> {result.rebuilt_overlay_offset:#x}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
