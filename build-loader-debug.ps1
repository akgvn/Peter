<#
.SYNOPSIS
    Builds Loader with VC6 under Wine for VS Code debugging on Windows.

.DESCRIPTION
    Requires PowerShell 7, uv (for Python), and the build-wine.ps1 prerequisites.
    Loader's Debug configuration uses /Z7 to embed debug information in its
    objects, which the VC6 linker collects into the executable's PDB.
    Updates the executable's PDB-reference record for the VS Code debugger.

    Writes Peter250src/Loader/Debug/Peter.exe and its matching Peter.pdb.
#>
[CmdletBinding()]
param(
    [string]$Image = "peter-wine",
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"

$output = Join-Path $PSScriptRoot "Peter250src/Loader/Debug"
$project = Get-Item -LiteralPath (Join-Path $PSScriptRoot "Peter250src/Loader/Peter.dsp")
# MSDEV's incremental build can retain objects after project options change.
# Recompile older objects so a switch from /Zi to /Z7 takes effect on first use.
$oldObjects = Get-ChildItem -LiteralPath $output -Filter "*.obj" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTimeUtc -lt $project.LastWriteTimeUtc }
& (Join-Path $PSScriptRoot "build-wine.ps1") -Image $Image -Rebuild:($Rebuild -or [bool]$oldObjects)
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

uv run --no-project python (Join-Path $PSScriptRoot "scripts/set-vc6-pdb-reference.py") (Join-Path $output "Peter.exe")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> Loader is ready for VS Code debugging." -ForegroundColor Green
