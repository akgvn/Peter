import argparse
import os
import shutil
import subprocess


def positive_integer(value):
    number = int(value)
    if number <= 0:
        raise argparse.ArgumentTypeError("must be a positive integer")
    return number


def require_tools(parser, *tools):
    for tool in tools:
        if shutil.which(tool) is None:
            parser.error(f"{tool} is not installed")


def require_display(parser):
    if not os.environ.get("DISPLAY"):
        parser.error("DISPLAY is unset; use the image's normal entrypoint")


def to_windows_path(path, timeout):
    return subprocess.check_output(
        ["winepath", "-w", str(path)], text=True, timeout=timeout
    ).strip()


def stop_wine():
    """Best-effort cleanup; preserve the original error."""
    try:
        subprocess.run(
            ["wineserver", "-k"], stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL, timeout=5, check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        pass


def terminate(signum, frame):
    raise SystemExit(128 + signum)


def exit_status(returncode):
    """Convert a subprocess signal return code to a conventional CLI status."""
    return returncode if returncode >= 0 else 128 - returncode
