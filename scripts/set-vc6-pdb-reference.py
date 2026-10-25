#!/usr/bin/env python3
r"""Make a VC6 executable's PDB reference discoverable by VS Code's debugger.

Usage:
    uv run --no-project python scripts/set-vc6-pdb-reference.py path/to/Peter.exe

WHY THIS IS NEEDED
------------------
The VC6 linker puts the source lines, functions, types, and locals into a PDB.
It also writes a small CodeView record in the executable identifying that PDB.
The record is a reference to the symbols, not the symbols themselves.

VC6 uses the legacy NB10 reference. The tested cppvsdbg/vsdbg debugger reports
"Binary was not built with debug information" for this executable, even though
Microsoft's DIA symbol API can read its matching PDB. Replacing that reference
with an equivalent RSDS record allows the actual debugger to load the same PDB,
hit source breakpoints, and display typed locals. A standalone DIA check alone
was not sufficient to discover this executable-side compatibility problem.

NB10 AND RSDS LAYOUTS
--------------------
The names are four-byte ASCII format signatures. Offsets/sizes are in bytes;
integer fields are little-endian.

    Offset  NB10                               Size
     0      ASCII "NB10"                         4
     4      Legacy offset (unused here)          4
     8      PDB timestamp signature              4
    12      PDB age                              4
    16      Null-terminated PDB path              variable

    Offset  RSDS                               Size
     0      ASCII "RSDS"                         4
     4      PDB GUID                             16
    20      PDB age                              4
    24      Null-terminated PDB path              variable

The timestamp is an opaque PDB identifier, not the EXE's timestamp or filesystem
modification time. The age is a database revision counter, not a duration.
Both identity and age must match: a matching filename is not enough.

For the tested PDB 2.00 files, DIA represents the legacy identity as a GUID whose
first DWORD (Data1) is the timestamp signature and whose other 12 bytes are zero.
We write exactly that GUID, copying the original age. We do not invent a random
GUID, bypass matching, or convert the PDB into PDB 7.0. The PDB is not opened or
modified; the caller supplies an executable from a correctly matched build.

HOW THE IN-PLACE PATCH WORKS
---------------------------
1. Read the PE32 headers and locate debug-directory entry 6.
2. Translate the directory's RVA into a file offset through its containing
   section. An RVA is not generally a raw file offset.
3. Find the IMAGE_DEBUG_TYPE_CODEVIEW entry (type 2). Follow PointerToRawData,
   not AddressOfRawData: VC6 can store this payload outside mapped sections.
4. Replace its NB10 payload with the equivalent RSDS payload. Use only the PDB
   filename (Peter.pdb) instead of Wine's absolute build path. RSDS has an
   eight-byte larger header, but the shorter name fits in this build's existing
   allocation. Peter.pdb needs 24 + 10 = 34 bytes including its null terminator.
5. Zero the unused tail and update SizeOfData. Keep the payload's location,
   executable code, section layout, file length, and PDB contents unchanged.

An existing RSDS reference is a no-op, so an incremental build need not rewrite
the EXE. A fresh VC6 link writes NB10 again; build-loader-debug.ps1 runs this
after every successful build. Validation and conversion happen in memory before
writing. A truncated image, unsupported format, or insufficient allocation fails
without writing a partial conversion. The PE checksum is not recomputed and
signed images are outside this debug-build workflow.

The debugger finds the PDB beside the EXE or through symbolSearchPath. Source
lookup is separate: sourceFileMap translates the Z:\workspace paths inside the
PDB to the local checkout. /Z7 embeds compiler debug data in OBJs; /Zi with
/PDBTYPE:CON is also verified. This patch does not consolidate /PDBTYPE:SEPT
type pools or repair their separate compatibility problem.

This is a dependency-free compatibility helper for the tested VC6 PE32 workflow,
not a general-purpose symbol converter. It needs neither DIA nor Visual Studio.

Reference:
    https://learn.microsoft.com/windows/win32/debug/pe-format#debug-directory-image-only
"""

from __future__ import annotations

import argparse
from pathlib import Path
import struct
import sys


DEBUG_DIRECTORY_INDEX = 6
DEBUG_DIRECTORY_SIZE = 28
CODEVIEW_TYPE = 2
SECTION_HEADER_SIZE = 40


def require_range(image: bytes, offset: int, size: int, description: str) -> None:
    """Reject an invalid file range before reading or changing it."""
    if offset < 0 or size < 0 or offset + size > len(image):
        raise ValueError(f"Truncated or invalid {description}")


def convert_pdb_reference(image: bytes, pdb_name: str) -> bytes:
    """Return a reference-patched PE32 image, or the original bytes for RSDS."""
    require_range(image, 0, 64, "DOS header")
    if image[:2] != b"MZ":
        raise ValueError("Expected a DOS MZ header")
    pe = struct.unpack_from("<I", image, 0x3C)[0]
    require_range(image, pe, 24, "PE/COFF header")
    if image[pe:pe + 4] != b"PE\0\0":
        raise ValueError("Expected a PE signature")

    section_count = struct.unpack_from("<H", image, pe + 6)[0]
    optional_size = struct.unpack_from("<H", image, pe + 20)[0]
    optional = pe + 24
    require_range(image, optional, optional_size, "optional header")
    if optional_size < 96 or struct.unpack_from("<H", image, optional)[0] != 0x10B:
        raise ValueError("Expected a PE32 optional header")
    directory_count = struct.unpack_from("<I", image, optional + 92)[0]
    debug_entry = optional + 96 + DEBUG_DIRECTORY_INDEX * 8
    if directory_count <= DEBUG_DIRECTORY_INDEX or optional_size < 96 + (DEBUG_DIRECTORY_INDEX + 1) * 8:
        raise ValueError("No debug data-directory entry")
    debug_rva, debug_size = struct.unpack_from("<II", image, debug_entry)
    if not debug_rva or not debug_size:
        raise ValueError("No debug directory")
    if debug_size % DEBUG_DIRECTORY_SIZE:
        raise ValueError("Invalid debug-directory size")

    sections = optional + optional_size
    require_range(image, sections, section_count * SECTION_HEADER_SIZE, "section table")
    debug_offset = None
    for index in range(section_count):
        section = sections + index * SECTION_HEADER_SIZE
        rva, raw_size, raw_offset = struct.unpack_from("<III", image, section + 12)
        if rva <= debug_rva < rva + raw_size:
            within_section = debug_rva - rva
            if within_section + debug_size > raw_size:
                raise ValueError("Debug directory extends beyond its section's file data")
            debug_offset = raw_offset + within_section
            break
    if debug_offset is None:
        raise ValueError("No section contains the debug directory")
    require_range(image, debug_offset, debug_size, "debug directory")

    for entry in range(debug_offset, debug_offset + debug_size, DEBUG_DIRECTORY_SIZE):
        kind, size, _data_rva, offset = struct.unpack_from("<IIII", image, entry + 12)
        if kind != CODEVIEW_TYPE:
            continue
        require_range(image, offset, size, "CodeView record")
        if size < 4:
            raise ValueError("Truncated CodeView signature")
        signature = image[offset:offset + 4]
        if signature == b"RSDS":
            return image
        if signature != b"NB10":
            raise ValueError(f"Expected an NB10 PDB reference, found {signature!r}")
        if size < 17:
            raise ValueError("Truncated NB10 record")
        if b"\0" not in image[offset + 16:offset + size]:
            raise ValueError("NB10 PDB path is not null-terminated")
        if not pdb_name or "\0" in pdb_name:
            raise ValueError("Expected a nonempty PDB filename without null bytes")

        timestamp, age = struct.unpack_from("<II", image, offset + 8)
        # Data1 is the legacy PDB signature; the remaining GUID bytes are zero.
        record = struct.pack("<4sI12xI", b"RSDS", timestamp, age)
        record += pdb_name.encode("utf-8") + b"\0"
        if len(record) > size:
            raise ValueError(f"RSDS reference needs {len(record)} bytes; only {size} are available")

        patched = bytearray(image)
        patched[offset:offset + size] = record.ljust(size, b"\0")
        # SizeOfData changes; PointerToRawData and the file layout stay put.
        struct.pack_into("<I", patched, entry + 16, len(record))
        return bytes(patched)
    raise ValueError("No CodeView PDB reference")


def patch_executable(executable: Path) -> bool:
    """Patch the file only after conversion succeeds; return whether it changed."""
    path = executable.resolve()
    original = path.read_bytes()
    patched = convert_pdb_reference(original, path.with_suffix(".pdb").name)
    if patched == original:
        return False
    path.write_bytes(patched)
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Replace a VC6 PE32 NB10 PDB reference with equivalent RSDS metadata.")
    parser.add_argument("executable", type=Path, help="executable to patch in place; the PDB must have the same basename")
    args = parser.parse_args()
    try:
        changed = patch_executable(args.executable)
    except (OSError, ValueError) as error:
        print(f"{parser.prog}: {error}", file=sys.stderr)
        return 1
    print("Updated PDB reference for VS Code." if changed else "PDB reference already uses RSDS; unchanged.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
