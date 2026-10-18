#!/usr/bin/env python3
import argparse
from pathlib import Path
import signal
import subprocess
import sys
import tempfile

from wine_common import (
    exit_status,
    positive_integer,
    require_display,
    require_tools,
    stop_wine,
    terminate,
    to_windows_path,
)


def build(source, configuration, action, timeout):
    def run_wine(*arguments):
        subprocess.run(["wine", *arguments], cwd=source.parent,
                       timeout=timeout, check=True)

    if source.suffix.lower() == ".mak":
        command = ["nmake", "/nologo", "/f", source.name, "NO_EXTERNAL_DEPS=1"]
        if configuration is not None:
            command.append(f"CFG={configuration}")
        if action in {"clean", "rebuild"}:
            run_wine(*command, "CLEAN")
        if action != "clean":
            run_wine(*command)
        return

    with tempfile.TemporaryDirectory(prefix="peter-build-") as directory:
        log = Path(directory) / "build.log"
        windows_log = to_windows_path(log, timeout)
        command = ["msdev", source.name, "/MAKE", configuration,
                   "/USEENV", "/OUT", windows_log]
        if action == "rebuild":
            command.append("/REBUILD")
        elif action == "clean":
            command.append("/CLEAN")
        try:
            run_wine(*command)
        finally:
            # MSDEV writes its diagnostics to /OUT, including on build failure.
            if log.is_file():
                print(log.read_text(encoding="cp1250", errors="replace"),
                      end="", flush=True)


def main():
    parser = argparse.ArgumentParser(
        description="Build VC6 projects: .dsp/.dsw use MSDEV; .mak uses NMAKE."
    )
    parser.add_argument("source", type=Path, metavar="PROJECT.dsp|WORKSPACE.dsw|PROJECT.mak")
    parser.add_argument("--config",
                        help="native configuration/target passed verbatim; defaults to "
                             "the makefile's CFG or MSDEV's ALL - Release")
    actions = parser.add_mutually_exclusive_group()
    actions.add_argument("--rebuild", action="store_true", help="clean, then build")
    actions.add_argument("--clean", action="store_true", help="clean only")
    parser.add_argument("--timeout", type=positive_integer, default=300,
                        help="timeout for each build/clean command in seconds (default: 300)")
    args = parser.parse_args()
    if args.config == "":
        parser.error("--config must not be empty")
    source = args.source.resolve()
    if not source.is_file() or source.suffix.lower() not in {".dsp", ".dsw", ".mak"}:
        parser.error(f"expected an existing .dsp, .dsw, or .mak file: {args.source}")
    tools = ["wine", "wineserver"]
    if source.suffix.lower() != ".mak":
        tools.append("winepath")
        require_display(parser)
    require_tools(parser, *tools)
    configuration = args.config
    if configuration is None and source.suffix.lower() != ".mak":
        configuration = "ALL - Release"
    action = "rebuild" if args.rebuild else "clean" if args.clean else "build"
    print(f"Building {source} [{configuration or 'makefile default'}], action: {action}",
          flush=True)

    signal.signal(signal.SIGTERM, terminate)
    try:
        build(source, configuration, action, args.timeout)
    except subprocess.TimeoutExpired:
        print(f"{parser.prog}: command timed out after {args.timeout}s", file=sys.stderr)
        return 124
    except subprocess.CalledProcessError as error:
        return exit_status(error.returncode)
    except OSError as error:
        print(f"{parser.prog}: {error}", file=sys.stderr)
        return 1
    finally:
        stop_wine()
    print("Build action complete.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(130)
