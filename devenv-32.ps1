<#
.SYNOPSIS
    Launches a Visual Studio Developer PowerShell with the x86 (32-bit) C++ build tools loaded.

.DESCRIPTION
    Run from the repository root on Windows (e.g. `.\devenv-32.ps1`). Uses vswhere to find
    the latest Visual Studio installation with x86/x64 C++ tools and loads its x86 dev shell,
    so tools like nmake and cl build 32-bit binaries.

.EXAMPLE
    .\devenv-32.ps1
    nmake /f Peter.mak NO_EXTERNAL_DEPS=1 CFG="Loader - Win32 Release"
#>

# Run from the repository root regardless of the caller's current directory.
Push-Location $PSScriptRoot

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = & $vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath

$devShell = Join-Path $vsPath "Common7\Tools\Launch-VsDevShell.ps1"

& $devShell -Arch x86 -HostArch amd64 -SkipAutomaticLocation
