$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vsPath = & $vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath

$devShell = Join-Path $vsPath "Common7\Tools\Launch-VsDevShell.ps1"

& $devShell -Arch x86 -HostArch amd64 -SkipAutomaticLocation

Push-Location ./Peter250src/Loader
nmake /f Peter.mak  CFG="Loader - Win32 Release"
nmake /f Peter.mak  CFG="Loader - Win32 Release Mini"
Pop-Location

Push-Location ./Peter250src/Loader0
nmake /f Peter.mak CFG="Loader0 - Win32 Release"
Pop-Location

Push-Location ./Peter250src
nmake /f Peter.mak CFG="Peter - Win32 Release"
Pop-Location