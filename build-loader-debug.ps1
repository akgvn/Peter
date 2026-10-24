<#
.SYNOPSIS
    Builds Loader with VC6 under Wine, then links a modern PDB for VS Code.

.DESCRIPTION
    Requires PowerShell 7, the build-wine.ps1 prerequisites, and Visual Studio
    or Build Tools with the Desktop development with C++ workload installed.
    Loader's Debug configuration uses /Z7 so its objects contain debug information
    that the modern linker can read without opening a VC6 compiler PDB.

    Writes Debug/Peter-vscode.exe and Debug/Peter-vscode.pdb alongside the VC6
    build outputs.
#>
[CmdletBinding()]
param(
    [string]$Image = "peter-wine",
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"

try {
    & (Join-Path $PSScriptRoot "devenv-32.ps1")
} finally {
    # devenv-32.ps1 pushes the repository root onto the location stack.
    Pop-Location
}

$output = Join-Path $PSScriptRoot "Peter250src/Loader/Debug"
$project = Get-Item -LiteralPath (Join-Path $PSScriptRoot "Peter250src/Loader/Peter.dsp")
# MSDEV's incremental build can retain objects after project options change.
# Recompile older objects so a switch from /Zi to /Z7 takes effect on first use.
$oldObjects = Get-ChildItem -LiteralPath $output -Filter "*.obj" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTimeUtc -lt $project.LastWriteTimeUtc }
& (Join-Path $PSScriptRoot "build-wine.ps1") -Image $Image -Rebuild:($Rebuild -or [bool]$oldObjects)
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> Linking Loader with modern Windows debug symbols..."
# Match the libraries and options of Loader - Win32 Debug in Peter.dsp.
& link.exe /nologo /subsystem:windows /incremental:no /debug /machine:I386 /nodefaultlib `
    "/out:$output/Peter-vscode.exe" "/pdb:$output/Peter-vscode.pdb" `
    "$output/*.obj" "$output/Resource.res" `
    kernel32.lib user32.lib gdi32.lib winspool.lib msacm32.lib winmm.lib `
    comdlg32.lib comctl32.lib advapi32.lib shell32.lib ole32.lib uuid.lib `
    (Join-Path $PSScriptRoot "Peter250src/Lib/Tran.lib")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "==> Loader is ready for VS Code debugging." -ForegroundColor Green
exit 0
