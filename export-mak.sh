#!/usr/bin/env bash
# Run in a dedicated Wine container/prefix; cleanup stops its Wine processes.
set -euo pipefail

usage() {
    cat <<'HELP'
Usage: export-mak.sh [--timeout SECONDS] PROJECT.dsp|WORKSPACE.dsw

Export fresh NMAKE .mak files beside the selected project(s), automatically
confirming the English VC6 Export Makefile(s) dialog under the image's Xvfb.
Paths are relative to the container's working directory. Default timeout: 60s.

Examples (repository mounted at /workspace):
  export-mak.sh Peter250src/Peter.dsw
  export-mak.sh --timeout 120 Peter250src/DelExe/DelExe.dsp
HELP
}

die() { printf 'export-mak.sh: %s\n' "$*" >&2; exit 2; }
timeout_seconds=60
input=
while (($#)); do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        --timeout)
            (($# >= 2)) || die '--timeout requires seconds'
            timeout_seconds=$2; shift 2 ;;
        --) shift; (($# == 1)) && [[ -z $input ]] || die 'expected one project/workspace'; input=$1; shift ;;
        -*) die "unknown option: $1" ;;
        *) [[ -z $input ]] || die 'expected one project/workspace'; input=$1; shift ;;
    esac
done
[[ $timeout_seconds =~ ^[1-9][0-9]*$ ]] || die '--timeout must be a positive integer'
[[ -n $input ]] || { usage >&2; exit 2; }
[[ -f $input ]] || die "file not found: $input"
case "${input,,}" in *.dsp|*.dsw) ;; *) die 'input must be a .dsp or .dsw file' ;; esac
for tool in wine wineserver xdotool; do
    command -v "$tool" >/dev/null || die "$tool is not installed"
done
[[ -n ${DISPLAY:-} ]] || die "DISPLAY is unset; use the image's normal entrypoint"

cd -- "$(dirname -- "$input")"
input=$(basename -- "$input")
projects=()
if [[ ${input,,} == *.dsp ]]; then
    projects+=("$input")
else
    while IFS= read -r project; do
        project=${project%$'\r'}
        project=${project#\"}
        project=${project%\"}
        project=${project//\\//}
        [[ ${project,,} == *.dsp ]] || die "unsupported workspace project: $project"
        [[ -f $project ]] || die "workspace project not found: $project"
        projects+=("$project")
    done < <(sed -n 's/^Project: "[^"]*"=[[:space:]]*\(.*\) - Package Owner=.*/\1/p' "$input")
fi
((${#projects[@]})) || die "no projects found in $input"

marker=$(mktemp)
cleanup() {
    rm -f -- "$marker"
    wineserver -k >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
deadline=$((SECONDS + timeout_seconds))
wine msdev "$input" /EX BuildProjectExport &
ide=$!

check_deadline() {
    if ((SECONDS >= deadline)); then
        printf 'export-mak.sh: export timed out after %ss\n' "$timeout_seconds" >&2
        exit 124
    fi
}

wait_for_window() {
    local window
    until window=$(xdotool search --onlyvisible --limit 1 --name "$1" 2>/dev/null); do
        check_deadline
        sleep 0.2
    done
    printf '%s\n' "$window"
}

dialog=$(wait_for_window '^Export Makefile\(s\)$')
xdotool windowfocus --sync "$dialog"
xdotool key --clearmodifiers Return
for project in "${projects[@]}"; do
    mak=${project%.*}.mak
    until [[ -s $mak && $mak -nt $marker ]]; do
        check_deadline
        sleep 0.2
    done
    printf 'Exported %s/%s\n' "$PWD" "$mak"
done
window=$(wait_for_window 'Microsoft Visual C\+\+$')
xdotool windowfocus --sync "$window"
xdotool key --clearmodifiers alt+F4
while kill -0 "$ide" 2>/dev/null; do
    check_deadline
    sleep 0.2
done
wait "$ide"
printf 'Export complete: %s project(s)\n' "${#projects[@]}"
