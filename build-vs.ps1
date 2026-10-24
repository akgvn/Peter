<#
.SYNOPSIS
    Builds Loader, Loader0 and Peter with the installed Visual Studio C++ tools.

.DESCRIPTION
    Run from the repository root on Windows. Loads the 32-bit dev tools via
    devenv-32.ps1, then builds Loader Release/Release Mini, Loader0 Release
    and Peter Release. Generate the NMAKE makefiles first with export-mak.ps1.

.EXAMPLE
    .\export-mak.ps1
    .\build-vs.ps1
#>

& $PSScriptRoot\devenv-32.ps1

Push-Location ./Peter250src/Loader
nmake /f Peter.mak NO_EXTERNAL_DEPS=1 CFG="Loader - Win32 Release"
nmake /f Peter.mak NO_EXTERNAL_DEPS=1 CFG="Loader - Win32 Release Mini"
Pop-Location

Push-Location ./Peter250src/Loader0
nmake /f Peter.mak NO_EXTERNAL_DEPS=1 CFG="Loader0 - Win32 Release"
Pop-Location

Push-Location ./Peter250src/Peter
nmake /f Peter.mak NO_EXTERNAL_DEPS=1 CFG="Peter - Win32 Release"
Pop-Location
