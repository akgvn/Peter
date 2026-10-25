"""Tests for the reference patch's preservation and rejection behavior.

Run with:
    uv run --no-project python -m unittest discover -s scripts -p test_set_vc6_pdb_reference.py
"""

import importlib.util
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("set-vc6-pdb-reference.py")
spec = importlib.util.spec_from_file_location("pdb_reference", SCRIPT)
patcher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(patcher)

DEBUG_ENTRY = 0x420
RECORD = 0x600  # Outside the mapped sections, just like the VC6 output.
ALLOCATION = 128
TIMESTAMP = 0x12345678
AGE = 7


def fixture() -> bytes:
    image = bytearray(RECORD + ALLOCATION)
    image[:2] = b"MZ"
    struct.pack_into("<I", image, 0x3C, 0x80)
    image[0x80:0x84] = b"PE\0\0"
    struct.pack_into("<HH", image, 0x84, 0x14C, 2)
    struct.pack_into("<H", image, 0x94, 224)
    optional = 0x98
    struct.pack_into("<H", image, optional, 0x10B)
    struct.pack_into("<I", image, optional + 92, 16)
    struct.pack_into("<II", image, optional + 96 + 6 * 8, 0x2020, 28)
    sections = optional + 224
    image[sections:sections + 8] = b".text\0\0\0"
    struct.pack_into("<IIII", image, sections + 8, 0x100, 0x1000, 0x200, 0x200)
    image[0x200:0x206] = b"\xB8\x2A\0\0\0\xC3"
    sections += 40
    image[sections:sections + 8] = b".rdata\0\0"
    struct.pack_into("<IIII", image, sections + 8, 0x100, 0x2000, 0x200, 0x400)
    struct.pack_into("<IIII", image, DEBUG_ENTRY + 12, 2, ALLOCATION, 0, RECORD)
    record = struct.pack("<4sIII", b"NB10", 0, TIMESTAMP, AGE)
    record += b"Z:\\workspace\\build\\sample.pdb\0"
    image[RECORD:RECORD + len(record)] = record
    return bytes(image)


class ReferencePatchTests(unittest.TestCase):
    def test_preserves_code_layout_identity_and_all_unrelated_bytes(self):
        original = fixture()
        patched = patcher.convert_pdb_reference(original, "sample.pdb")
        expected = b"RSDS" + struct.pack("<I", TIMESTAMP) + bytes(12) + struct.pack("<I", AGE) + b"sample.pdb\0"
        self.assertEqual(len(original), len(patched))
        self.assertEqual(patched[RECORD:RECORD + len(expected)], expected)
        self.assertEqual(patched[RECORD + len(expected):], bytes(ALLOCATION - len(expected)))
        self.assertEqual(struct.unpack_from("<I", patched, DEBUG_ENTRY + 16)[0], len(expected))
        permitted = set(range(DEBUG_ENTRY + 16, DEBUG_ENTRY + 20)) | set(range(RECORD, RECORD + ALLOCATION))
        self.assertTrue(all(i in permitted for i, (a, b) in enumerate(zip(original, patched)) if a != b))
        self.assertEqual(patcher.convert_pdb_reference(patched, "sample.pdb"), patched)

    def test_filename_is_utf8_and_null_terminated(self):
        name = "příliš.pdb"
        patched = patcher.convert_pdb_reference(fixture(), name)
        expected = name.encode("utf-8") + b"\0"
        self.assertEqual(patched[RECORD + 24:RECORD + 24 + len(expected)], expected)

    def test_invalid_images_and_records_are_rejected_without_mutation(self):
        variants = []
        variants.append(b"MZ")
        image = bytearray(fixture())
        image[:2] = b"NO"
        variants.append(bytes(image))
        image = bytearray(fixture())
        struct.pack_into("<H", image, 0x98, 0x20B)
        variants.append(bytes(image))
        image = bytearray(fixture())
        struct.pack_into("<II", image, 0x98 + 96 + 48, 0, 0)
        variants.append(bytes(image))
        image = bytearray(fixture())
        struct.pack_into("<I", image, DEBUG_ENTRY + 24, len(image) + 1)
        variants.append(bytes(image))
        image = bytearray(fixture())
        image[RECORD:RECORD + 4] = b"NB11"
        variants.append(bytes(image))
        image = bytearray(fixture())
        struct.pack_into("<I", image, DEBUG_ENTRY + 16, 17)
        variants.append(bytes(image))  # No null terminator in the declared path.
        for original in variants:
            with self.subTest(prefix=original[:8], length=len(original)):
                before = bytes(original)
                with self.assertRaises(ValueError):
                    patcher.convert_pdb_reference(original, "sample.pdb")
                self.assertEqual(original, before)
        with self.assertRaisesRegex(ValueError, "only 128 are available"):
            patcher.convert_pdb_reference(fixture(), "x" * 128 + ".pdb")

    def test_cli_patches_in_place_and_keeps_pdb_and_second_run_unchanged(self):
        with tempfile.TemporaryDirectory(prefix="pdb reference ") as directory:
            image = Path(directory) / "sample.exe"
            image.write_bytes(fixture())
            pdb = image.with_suffix(".pdb")
            pdb.write_bytes(b"An external PDB must not be opened or modified.")
            command = [sys.executable, str(SCRIPT), str(image)]
            first = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(first.returncode, 0, first.stderr)
            patched = image.read_bytes()
            modified = image.stat().st_mtime_ns
            second = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertIn("unchanged", second.stdout)
            self.assertEqual(image.read_bytes(), patched)
            self.assertEqual(image.stat().st_mtime_ns, modified)
            self.assertEqual(pdb.read_bytes(), b"An external PDB must not be opened or modified.")
            image.write_bytes(b"Not an executable")
            failure = subprocess.run(command, capture_output=True, text=True)
            self.assertNotEqual(failure.returncode, 0)
            self.assertEqual(image.read_bytes(), b"Not an executable")


if __name__ == "__main__":
    unittest.main()
