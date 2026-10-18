#!/usr/bin/env python3
import argparse
from pathlib import Path
import signal
import subprocess
import sys
import time

from wine_common import (
    exit_status,
    positive_integer,
    require_display,
    require_tools,
    stop_wine,
    terminate,
)


WORKSPACE = Path("Peter250src/Peter.dsw")
MAKEFILES = (
    "DataInst/DataInst.mak",
    "DelExe/DelExe.mak",
    "Gener/Gener.mak",
    "Loader/Peter.mak",
    "Loader0/Peter.mak",
    "Peter/Peter.mak",
    "Pov2Spr/Pov2Spr.mak",
    "Setup/Setup.mak",
)


def export_makefiles(workspace, timeout):
    deadline = time.monotonic() + timeout
    started_at = time.time_ns()

    def remaining_time():
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError
        return remaining

    def run_xdotool(*arguments, search=False):
        return subprocess.run(
            ["xdotool", *arguments], timeout=remaining_time(), text=True,
            stdout=subprocess.PIPE if search else None,
            stderr=subprocess.DEVNULL if search else None, check=not search,
        )

    def wait_for_window(title):
        while True:
            result = run_xdotool(
                "search", "--onlyvisible", "--limit", "1", "--name", title,
                search=True,
            )
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip()
            time.sleep(0.2)

    process = subprocess.Popen(
        ["wine", "msdev", workspace.name, "/EX", "BuildProjectExport"],
        cwd=workspace.parent,
    )
    try:
        # Wine's launcher can exit before its IDE child; wait for the dialog.
        dialog = wait_for_window("Export Makefile")
        run_xdotool("windowfocus", "--sync", dialog)
        run_xdotool("key", "--clearmodifiers", "Return")

        for relative_path in MAKEFILES:
            makefile = workspace.parent / relative_path
            while True:
                remaining_time()
                try:
                    if makefile.is_file():
                        stat = makefile.stat()
                        if stat.st_size > 0 and stat.st_mtime_ns > started_at:
                            break
                except FileNotFoundError:
                    # MSDEV can replace an existing file between these checks.
                    pass
                time.sleep(0.2)
            print(f"Exported {makefile}", flush=True)

        window = wait_for_window("Microsoft Visual C")
        run_xdotool("windowfocus", "--sync", window)
        run_xdotool("key", "--clearmodifiers", "alt+F4")
        result = process.wait(timeout=remaining_time())
        if result:
            raise subprocess.CalledProcessError(result, "wine msdev")
    finally:
        stop_wine()
        if process.poll() is None:
            process.kill()
        process.wait()


def main():
    parser = argparse.ArgumentParser(
        description="Export all eight NMAKE .mak files from Peter250src/Peter.dsw, "
                    "automatically confirming the English export dialog."
    )
    parser.add_argument("--timeout", type=positive_integer, default=60,
                        help="overall export timeout in seconds (default: 60)")
    args = parser.parse_args()
    workspace = WORKSPACE.resolve()
    if not workspace.is_file():
        parser.error(f"workspace not found: {workspace}")
    require_tools(parser, "wine", "wineserver", "xdotool")
    require_display(parser)
    signal.signal(signal.SIGTERM, terminate)
    try:
        export_makefiles(workspace, args.timeout)
    except (TimeoutError, subprocess.TimeoutExpired):
        print(f"{parser.prog}: export timed out after {args.timeout}s", file=sys.stderr)
        return 124
    except subprocess.CalledProcessError as error:
        print(f"{parser.prog}: command failed: {error.cmd}", file=sys.stderr)
        return exit_status(error.returncode)
    except OSError as error:
        print(f"{parser.prog}: {error}", file=sys.stderr)
        return 1
    print(f"Export complete: {len(MAKEFILES)} makefile(s)")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
