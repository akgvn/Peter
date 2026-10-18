[CmdletBinding()]
param(
    [string]$Image = "peter-wine",
    [int]$Timeout = 60
)

$ErrorActionPreference = "Stop"

podman run --rm -v "${PSScriptRoot}:/workspace" $Image export-mak.py --timeout $Timeout
exit $LASTEXITCODE
