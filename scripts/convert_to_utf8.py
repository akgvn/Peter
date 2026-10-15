#!/usr/bin/env python3
"""Convert CP1250-encoded source files to UTF-8.

Covers .c/.cpp/.h/.rc/.txt/.rtf/.hpj files under the directory containing
this script. Binary formats and the mixed-encoding .inc language files are
intentionally skipped.

Line endings are preserved: the CP1250 -> UTF-8 transcode only affects
bytes >= 0x80, so CRLF sequences pass through untouched.

Usage:
    uv run convert_to_utf8.py [--dry-run]
"""

from __future__ import annotations

import argparse
import pathlib
import sys

EXTENSIONS = {".c", ".cpp", ".h", ".rc", ".txt", ".rtf", ".hpj"}
SKIP_DIRS = {".git"}


def iter_files(root: pathlib.Path):
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if any(part in SKIP_DIRS for part in path.parts):
            continue
        if path.suffix.lower() in EXTENSIONS:
            yield path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "root",
        nargs="?",
        type=pathlib.Path,
        default=pathlib.Path.cwd(),
        help="directory to scan (default: current directory)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="report what would be converted without writing anything",
    )
    args = parser.parse_args()

    sys.stdout.reconfigure(encoding="utf-8", errors="backslashreplace")

    root = args.root.resolve()
    if not root.is_dir():
        parser.error(f"not a directory: {root}")

    converted: list[pathlib.Path] = []
    already_utf8 = 0
    failed: list[tuple[pathlib.Path, str]] = []

    for path in iter_files(root):
        data = path.read_bytes()
        try:
            data.decode("utf-8")
        except UnicodeDecodeError:
            pass
        else:
            already_utf8 += 1
            continue
        try:
            text = data.decode("cp1250")
        except UnicodeDecodeError as exc:
            failed.append((path, str(exc)))
            continue
        if not args.dry_run:
            path.write_bytes(text.encode("utf-8"))
        converted.append(path)

    for path in converted:
        print(f"converted: {path.relative_to(root)}")
    for path, err in failed:
        print(f"FAILED:    {path.relative_to(root)} ({err})")

    verb = "would convert" if args.dry_run else "converted"
    print(
        f"\n{verb}: {len(converted)}, already UTF-8: {already_utf8}, "
        f"failed: {len(failed)}"
    )
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
