# /// script
# requires-python = ">=3.10"
# dependencies = ["lief==1.0.0"]
# ///
"""Run: uv run --no-project scripts/test_rebuild_pdb_reference.py -v"""

import importlib.util
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest

import lief


SCRIPT = Path(__file__).with_name("rebuild-pdb-reference.py")
spec = importlib.util.spec_from_file_location("rebuild_pdb_reference", SCRIPT)
rebuilder = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = rebuilder
spec.loader.exec_module(rebuilder)

TIMESTAMP = 0x12345678
AGE = 7


def fixture(*, pe64=False, mapped=False, extra_debug=False, duplicate=False,
            name=b"Z:\\workspace\\symbols\\original.pdb", record=None, footer=b"APPLICATION-FOOTER"):
    """A complete minimal PE with deliberately tiny CodeView storage and an overlay."""
    record = record if record is not None else struct.pack("<4sIII", b"NB10", 0, TIMESTAMP, AGE) + name + b"\0"
    image = bytearray(0x600)
    image[:2] = b"MZ"
    struct.pack_into("<I", image, 0x3C, 0x80)
    image[0x80:0x84] = b"PE\0\0"
    optional, optional_size = 0x98, 240 if pe64 else 224
    struct.pack_into("<HHIIIHH", image, 0x84, 0x8664 if pe64 else 0x14C, 2,
                     0x11223344, 0, 0, optional_size, 0x22 if pe64 else 0x102)
    struct.pack_into("<HBBIII", image, optional, 0x20B if pe64 else 0x10B, 6, 0, 0x200, 0x200, 0)
    struct.pack_into("<II", image, optional + 16, 0x1000, 0x1000)
    if pe64:
        struct.pack_into("<Q", image, optional + 24, 0x140000000)
        struct.pack_into("<QQQQ", image, optional + 72, 0x100000, 0x1000, 0x100000, 0x1000)
        struct.pack_into("<I", image, optional + 108, 16)
    else:
        struct.pack_into("<II", image, optional + 24, 0x2000, 0x400000)
        struct.pack_into("<IIII", image, optional + 72, 0x100000, 0x1000, 0x100000, 0x1000)
        struct.pack_into("<I", image, optional + 92, 16)
    struct.pack_into("<II", image, optional + 32, 0x1000, 0x200)
    struct.pack_into("<HHHHHH", image, optional + 40, 4, 0, 0, 0, 4, 0)
    struct.pack_into("<II", image, optional + 56, 0x3000, 0x200)
    struct.pack_into("<H", image, optional + 68, 3)
    directories = optional + (112 if pe64 else 96)
    count = 2 if extra_debug or duplicate else 1
    struct.pack_into("<II", image, directories + 6 * 8, 0x2020, count * 28)
    sections = optional + optional_size
    for index, (section_name, rva, raw, flags) in enumerate((
        (b".text", 0x1000, 0x200, 0x60000020),
        (b".rdata", 0x2000, 0x400, 0x40000040),
    )):
        header = sections + index * 40
        image[header:header + 8] = section_name.ljust(8, b"\0")
        struct.pack_into("<IIIIIIHHI", image, header + 8, 0x200, rva, 0x200, raw, 0, 0, 0, 0, flags)
    image[0x200:0x206] = b"\xB8\x2A\0\0\0\xC3"
    offset = 0x480 if mapped else 0x600
    struct.pack_into("<IIHHIIII", image, 0x420, 0, 0x55667788, 0, 0, 2,
                     len(record), 0x2080 if mapped else 0, offset)
    if mapped:
        if offset + len(record) > 0x4C0:
            raise ValueError("Test record too long")
        image[offset:offset + len(record)] = record
    else:
        image.extend(record)
    if duplicate:
        image[0x43C:0x458] = image[0x420:0x43C]
    elif extra_debug:
        # VC_FEATURE is a real structured entry with a nonempty payload, not
        # a marker: verify the library preserves it while replacing CodeView.
        struct.pack_into("<IIHHIIII", image, 0x43C, 0, 0x88776655, 1, 2, 12, 20, 0x20C0, 0x4C0)
        struct.pack_into("<IIIII", image, 0x4C0, 1, 2, 3, 4, 5)
    image.extend(footer)
    return bytes(image)


def codeview_bytes(image):
    binary = lief.PE.parse(image)
    entry = next(e for e in binary.debug if e.type == lief.PE.Debug.TYPES.CODEVIEW)
    return image[entry.pointerto_rawdata:entry.pointerto_rawdata + entry.sizeof_data]


class RebuildReferenceTests(unittest.TestCase):
    def test_rebuilds_pe32_and_pe64_with_mapped_and_file_only_payloads(self):
        for pe64 in (False, True):
            for mapped in (False, True):
                with self.subTest(pe64=pe64, mapped=mapped):
                    original = fixture(pe64=pe64, mapped=mapped, name=b"x.pdb")
                    reference = "C:\\symbols\\" + "a" * 200 + ".pdb"
                    result = rebuilder.rebuild_pdb_reference(original, reference)
                    expected = b"RSDS" + struct.pack("<I", TIMESTAMP) + bytes(12) + struct.pack("<I", AGE)
                    expected += reference.encode() + b"\0"
                    self.assertEqual(codeview_bytes(result.image), expected)
                    self.assertGreater(len(result.image), len(original))
                    before, after = lief.PE.parse(original), lief.PE.parse(result.image)
                    self.assertEqual(bytes(before.sections[0].content), bytes(after.sections[0].content))
                    self.assertEqual(bytes(before.overlay), bytes(after.overlay))
                    self.assertEqual(after.optional_header.checksum, after.compute_checksum())

    def test_preserves_original_pdb_basename_and_non_codeview_debug_entry(self):
        original = fixture(extra_debug=True, name=b"D:\\other-machine\\not-the-executable.pdb")
        result = rebuilder.rebuild_pdb_reference(original)
        self.assertEqual(result.pdb_reference, "not-the-executable.pdb")
        before, after = lief.PE.parse(original), lief.PE.parse(result.image)
        self.assertEqual([e.type for e in after.debug], [list(before.debug)[1].type, list(before.debug)[0].type])
        old, new = list(before.debug)[1], list(after.debug)[0]
        self.assertEqual(rebuilder.debug_metadata(old), rebuilder.debug_metadata(new))
        self.assertEqual(rebuilder.payload(original, old), rebuilder.payload(result.image, new))

    def test_unicode_reference_and_explicit_legacy_encoding(self):
        old_name = "C:\\symbols\\příliš.pdb".encode("cp1250")
        original = fixture(name=old_name)
        with self.assertRaisesRegex(ValueError, "Cannot decode"):
            rebuilder.rebuild_pdb_reference(original)
        result = rebuilder.rebuild_pdb_reference(original, nb10_encoding="cp1250")
        self.assertEqual(codeview_bytes(result.image)[24:], "příliš.pdb\0".encode("utf-8"))
        override = "C:\\symbols\\jiný.pdb"
        result = rebuilder.rebuild_pdb_reference(original, override)
        self.assertEqual(codeview_bytes(result.image)[24:], (override + "\0").encode("utf-8"))

    def test_reference_longer_than_max_path_is_not_truncated_in_the_pe(self):
        # This verifies record storage only, not Windows/debugger filesystem
        # support for opening such a path. The distinction is intentional.
        reference = "C:\\symbols" + "\\subdirectory" * 40 + "\\original.pdb"
        self.assertGreater(len(reference), 260)
        result = rebuilder.rebuild_pdb_reference(fixture(name=b"x.pdb"), reference)
        self.assertEqual(codeview_bytes(result.image)[24:], (reference + "\0").encode("utf-8"))

    def test_certificate_and_coff_symbol_table_images_are_explicitly_rejected(self):
        original = bytearray(fixture())
        certificate = len(original)
        original.extend(struct.pack("<IHH", 8, 0x200, 2))
        struct.pack_into("<II", original, 0x98 + 96 + 4 * 8, certificate, 8)
        with self.assertRaisesRegex(ValueError, "certificate-bearing"):
            rebuilder.rebuild_pdb_reference(bytes(original))
        original = bytearray(fixture())
        symbols = len(original)
        original.extend(struct.pack("<I", 4))  # Empty, well-formed COFF string table.
        struct.pack_into("<I", original, 0x80 + 12, symbols)
        with self.assertRaisesRegex(ValueError, "COFF symbol"):
            rebuilder.rebuild_pdb_reference(bytes(original))

    def test_already_rsds_is_copied_byte_for_byte(self):
        original = fixture(record=b"RSDS" + bytes(16) + struct.pack("<I", AGE) + b"original.pdb\0")
        result = rebuilder.rebuild_pdb_reference(original)
        self.assertFalse(result.changed)
        self.assertEqual(result.image, original)
        with self.assertRaisesRegex(ValueError, "already|existing RSDS"):
            rebuilder.rebuild_pdb_reference(original, "different.pdb")

    def test_rejects_ambiguous_unsupported_and_invalid_inputs(self):
        with self.assertRaisesRegex(ValueError, "exactly one"):
            rebuilder.rebuild_pdb_reference(fixture(duplicate=True))
        with self.assertRaisesRegex(ValueError, "NB10"):
            rebuilder.rebuild_pdb_reference(fixture(record=b"NB11" + bytes(40)))
        with self.assertRaises(ValueError):
            rebuilder.rebuild_pdb_reference(b"Not an executable")
        with self.assertRaisesRegex(ValueError, "null bytes"):
            rebuilder.rebuild_pdb_reference(fixture(), "bad\0name.pdb")
        with self.assertRaisesRegex(ValueError, "null-terminated"):
            rebuilder.rebuild_pdb_reference(fixture(record=b"NB10" + bytes(12) + b"no-null"))

    def test_preservation_check_detects_code_changes(self):
        original = fixture()
        result = rebuilder.rebuild_pdb_reference(original)
        before, after = lief.PE.parse(original), lief.PE.parse(result.image)
        changed = bytearray(result.image)
        changed[after.sections[0].pointerto_raw_data] ^= 1
        with self.assertRaisesRegex(ValueError, "non-debug bytes"):
            rebuilder.verify_rebuild(original, before, bytes(changed), after, 0, codeview_bytes(result.image))

    def test_cli_uses_separate_output_and_does_not_touch_input_or_pdb(self):
        with tempfile.TemporaryDirectory(prefix="rebuild pdb ") as directory:
            source = Path(directory) / "renamed.exe"
            output = Path(directory) / "different-output.exe"
            original = fixture(name=b"original.pdb")
            source.write_bytes(original)
            pdb = Path(directory) / "original.pdb"
            pdb.write_bytes(b"Do not read or modify this PDB")
            command = [sys.executable, str(SCRIPT), str(source), "-o", str(output)]
            run = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(run.returncode, 0, run.stderr)
            self.assertEqual(source.read_bytes(), original)
            self.assertEqual(pdb.read_bytes(), b"Do not read or modify this PDB")
            self.assertEqual(codeview_bytes(output.read_bytes())[24:], b"original.pdb\0")
            refusal = subprocess.run([sys.executable, str(SCRIPT), str(source), "-o", str(source)],
                                     capture_output=True, text=True)
            self.assertNotEqual(refusal.returncode, 0)
            self.assertEqual(source.read_bytes(), original)
            output.write_bytes(b"Existing output must survive a validation failure")
            source.write_bytes(b"invalid")
            failed = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(failed.returncode, 0)
            self.assertEqual(output.read_bytes(), b"Existing output must survive a validation failure")
            self.assertEqual(list(Path(directory).glob("*.tmp")), [])


if __name__ == "__main__":
    unittest.main()
