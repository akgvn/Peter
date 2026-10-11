#!/usr/bin/env uv

# /// script
# requires-python = ">=3.13"
# dependencies = []
# ///

# Brought to you (mostly) by Gemini 3.8 Flash.
# Scanning for encodings is tedious business.

import os
import re
import sys
from collections import defaultdict
from pathlib import Path

# File extension mappings to human-readable categories
CATEGORY_MAP = {
    # C/C++ Source
    ".c": "C Source (.c)",
    ".cpp": "C++ Source (.cpp)",
    ".cxx": "C++ Source (.cxx)",
    ".cc": "C++ Source (.cc)",
    # Headers & Includes
    ".h": "Header (.h)",
    ".hpp": "Header (.hpp)",
    ".hxx": "Header (.hxx)",
    ".inl": "Inline Header (.inl)",
    ".inc": "Include File (.inc)",
    # Windows Resources
    ".rc": "Resource Script (.rc)",
    ".rc2": "Resource Script (.rc2)",
    ".def": "Module Definition (.def)",
    ".idl": "Interface Definition (.idl)",
    # Project & Build Files
    ".dsp": "MSVC Project (.dsp)",
    ".dsw": "MSVC Workspace (.dsw)",
    ".mak": "Makefile (.mak)",
    # Documentation & Plain Text
    ".txt": "Text (.txt)",
    ".md": "Markdown (.md)",
    ".doc": "Doc (.doc)",
}

# Directories to ignore
IGNORE_DIRS = {".git", ".vs", "Debug", "Release", "obj", "bin", ".idea"}

# In Windows-1250, these bytes are undefined/invalid.
CP1250_UNDEFINED_BYTES = {0x81, 0x83, 0x88, 0x90, 0x98}

# Common Czech / Slovak characters
CZECH_SLOVAK_CHARS = set("áčďéěíňóřšťúůýžÁČĎÉĚÍŇÓŘŠŤÚŮÝŽľĺŕäôĽĹŔÄÔ")


def score_ce_text(text: str) -> int:
    score = 0
    words = re.findall(r'[A-Za-z\u0080-\u024F]+', text)
    for word in words:
        if any(ch in CZECH_SLOVAK_CHARS for ch in word):
            score += 15
    box_chars = sum(1 for ch in text if 0x2500 <= ord(ch) <= 0x257F)
    score -= box_chars * 10
    control_chars = len(re.findall(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', text))
    score -= control_chars * 20
    return score


def detect_file_encoding(raw_bytes: bytes) -> str:
    if b'\x00' in raw_bytes:
        return "BINARY"

    if all(b < 128 for b in raw_bytes):
        return "ASCII"

    try:
        raw_bytes.decode("utf-8")
        return "UTF-8"
    except UnicodeDecodeError:
        pass

    for b in raw_bytes:
        if b in CP1250_UNDEFINED_BYTES:
            return "CP-852"

    try:
        t1250 = raw_bytes.decode("cp1250")
    except UnicodeDecodeError:
        t1250 = ""

    try:
        t852 = raw_bytes.decode("cp852")
    except UnicodeDecodeError:
        t852 = ""

    return "CP-1250" if score_ce_text(t1250) >= score_ce_text(t852) else "CP-852"


def inspect_inc_files(inc_files: list[tuple[Path, bytes]]):
    """Special inspection for .inc localization files."""
    print("\n" + "=" * 78)
    print("DETAILED INSPECTION: .inc LOCALIZATION FILES")
    print("=" * 78)
    header = f"{'FILENAME':<22} | {'DECLARED CP':<12} | {'DECODES AS CP-1250?':<22} | {'SAMPLE'}"
    print(header)
    print("-" * 78)

    for path, raw in sorted(inc_files, key=lambda x: x[0].name):
        # Look for declared code page numbers in first 5 lines (e.g. // 1252)
        raw_lines = raw.splitlines()[:5]
        declared_cp = "None"
        for line in raw_lines:
            text_line = line.decode("latin1", errors="replace")
            m = re.search(r'\b(125\d|85\d|932|936|949|950)\b', text_line)
            if m:
                declared_cp = m.group(1)
                break

        # Test if it decodes cleanly under CP-1250
        sample_text = ""
        try:
            decoded = raw.decode("cp1250")
            can_decode_1250 = "YES (clean)"
            # Find a line with non-ascii text to display as a sample
            for line in decoded.splitlines():
                if any(ord(c) > 127 for c in line):
                    # Clean out control chars/newlines for sample display
                    sample_text = line.strip().replace("\t", " ")
                    if len(sample_text) > 28:
                        sample_text = sample_text[:28] + "..."
                    break
        except UnicodeDecodeError as e:
            can_decode_1250 = f"NO (error: byte 0x{raw[e.start]:02X})"

        print(f"{path.name:<22} | {declared_cp:<12} | {can_decode_1250:<22} | {sample_text}")


def scan_and_categorize(repo_path: str = "."):
    repo = Path(repo_path)

    stats = defaultdict(lambda: defaultdict(int))
    files_by_encoding = defaultdict(list)
    inc_files = []

    for root, dirs, files in os.walk(repo):
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]

        for file in files:
            file_path = Path(root) / file
            ext = file_path.suffix.lower()

            if ext not in CATEGORY_MAP:
                continue

            category = CATEGORY_MAP[ext]

            try:
                raw_bytes = file_path.read_bytes()
            except Exception as e:
                print(f"Error reading {file_path}: {e}", file=sys.stderr)
                continue

            encoding = detect_file_encoding(raw_bytes)
            stats[category][encoding] += 1
            rel_path = file_path.relative_to(repo)
            files_by_encoding[encoding].append((rel_path, category))

            if ext == ".inc":
                inc_files.append((rel_path, raw_bytes))

    # 1. Print Matrix Table
    print("\n" + "=" * 78)
    print("ENCODING BREAKDOWN BY FILE TYPE")
    print("=" * 78)
    header = f"{'FILE TYPE':<26} | {'ASCII':>7} | {'CP-1250':>7} | {'CP-852':>7} | {'UTF-8':>7} | {'TOTAL':>7}"
    print(header)
    print("-" * 78)

    totals = defaultdict(int)

    for category in sorted(stats.keys()):
        row = stats[category]
        c_ascii = row["ASCII"]
        c_1250 = row["CP-1250"]
        c_852 = row["CP-852"]
        c_utf8 = row["UTF-8"]
        c_total = sum(row.values())

        totals["ASCII"] += c_ascii
        totals["CP-1250"] += c_1250
        totals["CP-852"] += c_852
        totals["UTF-8"] += c_utf8
        totals["TOTAL"] += c_total

        print(f"{category:<26} | {c_ascii:>7} | {c_1250:>7} | {c_852:>7} | {c_utf8:>7} | {c_total:>7}")

    print("-" * 78)
    print(
        f"{'TOTALS':<26} | {totals['ASCII']:>7} | {totals['CP-1250']:>7} | "
        f"{totals['CP-852']:>7} | {totals['UTF-8']:>7} | {totals['TOTAL']:>7}"
    )
    print("=" * 78)

    # 2. Detailed Inspection of .inc files if any exist
    if inc_files:
        inspect_inc_files(inc_files)

    # 3. Detail Non-Standard Files (UTF-8, CP-852, BINARY)
    noteworthy_encodings = ["UTF-8", "CP-852", "BINARY"]
    found_noteworthy = False

    for enc in noteworthy_encodings:
        items = files_by_encoding[enc]
        if items:
            found_noteworthy = True
            print(f"\n[!] Files detected as {enc} ({len(items)} file{'s' if len(items) > 1 else ''}):")
            for path, cat in items:
                print(f"    - {path}  ({cat})")

    if not found_noteworthy:
        print("\nAll files are strictly ASCII or CP-1250.")


if __name__ == "__main__":
    scan_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    scan_and_categorize(scan_dir)
