#!/usr/bin/env bash
# Run in a dedicated Wine container/prefix; cleanup stops its Wine processes.
set -euo pipefail

usage() {
    cat <<'HELP'
Usage: build-project.sh [OPTIONS] PROJECT.dsp|WORKSPACE.dsw|PROJECT.mak

Build with MSVC 6.0: .dsp/.dsw use msdev; .mak uses NMAKE.
Paths are relative to the container's working directory.

Options:
  --config CONFIG   Configuration name (default: Release). For a project, a
                    short name such as Debug or an exact VC6 name is accepted.
                    For a workspace, Release/Debug select all projects; an
                    exact name such as "Loader - Win32 Release" selects one.
  --rebuild         Clean, then build.
  --clean           Clean only.
  --timeout SECONDS Limit each build/clean command (default: 300).
  -h, --help        Show this help.

Examples:
  build-project.sh --rebuild Peter250src/DelExe/DelExe.dsp
  build-project.sh --config Debug Peter250src/DelExe/DelExe.mak
  build-project.sh --config "Gener - Win32 Release MINI" Peter250src/Gener/Gener.dsp
HELP
}

die() { printf 'build-project.sh: %s\n' "$*" >&2; exit 2; }
configuration=Release
mode=build
timeout_seconds=300
input=
while (($#)); do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --config|--timeout)
            (($# >= 2)) || die "$1 requires a value"
            if [[ $1 == --config ]]; then configuration=$2; else timeout_seconds=$2; fi
            shift 2 ;;
        --rebuild|--clean)
            [[ $mode == build ]] || die '--rebuild and --clean are mutually exclusive'
            mode=${1#--}; shift ;;
        --) shift; (($# == 1)) && [[ -z $input ]] || die 'expected one project/workspace'; input=$1; shift ;;
        -*) die "unknown option: $1" ;;
        *) [[ -z $input ]] || die 'expected one project/workspace'; input=$1; shift ;;
    esac
done
[[ $timeout_seconds =~ ^[1-9][0-9]*$ ]] || die '--timeout must be a positive integer'
[[ -n $configuration ]] || die '--config must not be empty'
[[ -n $input ]] || { usage >&2; exit 2; }
[[ -f $input ]] || die "file not found: $input"
case "${input,,}" in *.dsp|*.dsw|*.mak) ;; *) die 'input must be a .dsp, .dsw, or .mak file' ;; esac
for tool in wine wineserver timeout; do
    command -v "$tool" >/dev/null || die "$tool is not installed"
done

cd -- "$(dirname -- "$input")"
input=$(basename -- "$input")
if [[ ${input,,} == *.dsw ]]; then
    [[ $configuration == *' - '* ]] || configuration="ALL - $configuration"
else
    matches=()
    while IFS= read -r candidate; do
        candidate=${candidate%$'\r'}
        if [[ $candidate == "$configuration" || $candidate == *" - Win32 $configuration" ]]; then
            matches+=("$candidate")
        fi
    done < <(sed -n 's/^!MESSAGE "\([^"]*\)" (based on .*/\1/p' "$input")
    ((${#matches[@]} == 1)) || die "configuration not found or ambiguous: $configuration (see $input)"
    configuration=${matches[0]}
fi

log=
cleanup() {
    [[ -z $log ]] || rm -f -- "$log"
    wineserver -k >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

run_wine() {
    local result=0
    timeout -k 5s "${timeout_seconds}s" wine "$@" || result=$?
    # GNU timeout returns 124; BusyBox timeout may return the terminating signal.
    if [[ $result == 124 || $result == 137 || $result == 143 ]]; then
        printf 'build-project.sh: command timed out after %ss\n' "$timeout_seconds" >&2
        return 124
    fi
    return "$result"
}

printf 'Building %s/%s [%s], action: %s\n' "$PWD" "$input" "$configuration" "$mode"
if [[ ${input,,} == *.mak ]]; then
    nmake=(nmake /nologo /f "$input" NO_EXTERNAL_DEPS=1 "CFG=$configuration")
    if [[ $mode == clean || $mode == rebuild ]]; then run_wine "${nmake[@]}" CLEAN; fi
    if [[ $mode != clean ]]; then run_wine "${nmake[@]}"; fi
else
    [[ -n ${DISPLAY:-} ]] || die "DISPLAY is unset; use the image's normal entrypoint"
    log=$(mktemp)
    windows_log=$(winepath -w "$log")
    msdev=(msdev "$input" /MAKE "$configuration" /USEENV /OUT "$windows_log")
    case "$mode" in rebuild) msdev+=(/REBUILD) ;; clean) msdev+=(/CLEAN) ;; esac
    result=0
    run_wine "${msdev[@]}" || result=$?
    cat -- "$log"
    ((result == 0)) || exit "$result"
fi
printf 'Build action complete.\n'
