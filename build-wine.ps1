<#
.SYNOPSIS
    Builds the Peter configuration matrix using build-project.py in the
    Wine + MSVC 6.0 image defined by build-tooling-msvc6/Containerfile.wine.

.DESCRIPTION
    Reuses the image if it already exists (building it only when it is missing),
    runs each configuration in a throwaway container with this repository
    mounted at /workspace, and stops on the first failure.
    Builds .dsp projects with MSDEV by default. Use -UseNMake for exported .mak
    files, generated separately with export-mak.ps1.

    podman on Windows needs its VM running first: `podman machine start`.

.EXAMPLE
    ./build-wine.ps1
    Use the existing image, or build it first if it does not exist yet.

.EXAMPLE
    ./build-wine.ps1 -RebuildImage
    Force the image to be rebuilt before running the build.

.EXAMPLE
    ./build-wine.ps1 -NoImageCheck
    Skip the image existence query and just run against the existing image.

.EXAMPLE
    ./export-mak.ps1
    ./build-wine.ps1 -UseNMake
    Export makefiles explicitly, then build them with NMAKE.
#>
[CmdletBinding()]
param(
    [string]$Image = "peter-wine",
    [switch]$RebuildImage,
    [switch]$NoImageCheck,
    [switch]$UseNMake,
    [switch]$LoaderDebug
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    throw "podman was not found on PATH."
}

$repo = $PSScriptRoot
$tooling = Join-Path $repo "build-tooling-msvc6"
$buildImage = [bool]$RebuildImage
$projectExtension = if ($UseNMake) { "mak" } else { "dsp" }

if (-not $buildImage) {
    if ($NoImageCheck) {
        Write-Host "==> Skipping image check; assuming '$Image' exists."
    } else {
        Write-Host "==> Checking for image '$Image'..."
        podman image inspect $Image *> $null
        if ($LASTEXITCODE -ne 0) {
            $buildImage = $true
        } else {
            Write-Host "==> Using existing image '$Image'."
        }
    }
}

if ($buildImage) {
    Write-Host "==> Building image '$Image' (this can take a while)..."
    podman build -t $Image -f (Join-Path $tooling "Containerfile.wine") $tooling
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Invoke-ProjectBuild {
    param([string]$Project, [string]$Configuration)

    $projectFile = "$Project.$projectExtension"
    Write-Host "==> $projectFile [$Configuration]"
    podman run --rm -v "${repo}:/workspace" $Image build-project.py --config $Configuration "Peter250src/$projectFile"
    $code = $LASTEXITCODE
    if ($code -ne 0) {
        Write-Host "==> Build failed (exit $code)." -ForegroundColor Red
        exit $code
    }
}


if ($LoaderDebug) {
    Invoke-ProjectBuild "Loader/Peter" "Loader - Win32 Debug"
} else {
    # Build DelExe first, then alphabetically, with Loader before Peter.
    Invoke-ProjectBuild "DelExe/DelExe" "DelExe - Win32 Release"
    Invoke-ProjectBuild "DelExe/DelExe" "DelExe - Win32 Debug"

    Invoke-ProjectBuild "DataInst/DataInst" "DataInst - Win32 Release"
    Invoke-ProjectBuild "DataInst/DataInst" "DataInst - Win32 Debug"

    Invoke-ProjectBuild "Gener/Gener" "Gener - Win32 Release"
    Invoke-ProjectBuild "Gener/Gener" "Gener - Win32 Release MINI"
    Invoke-ProjectBuild "Gener/Gener" "Gener - Win32 Install"
    Invoke-ProjectBuild "Gener/Gener" "Gener - Win32 Debug"

    Invoke-ProjectBuild "Loader/Peter" "Loader - Win32 Release"
    Invoke-ProjectBuild "Loader/Peter" "Loader - Win32 Release Mini"
    Invoke-ProjectBuild "Loader/Peter" "Loader - Win32 Debug"
    Invoke-ProjectBuild "Loader/Peter" "Loader - Win32 Debug Optim"

    Invoke-ProjectBuild "Loader0/Peter" "Loader0 - Win32 Release"
    Invoke-ProjectBuild "Loader0/Peter" "Loader0 - Win32 Debug"

    Invoke-ProjectBuild "Peter/Peter" "Peter - Win32 Release"
    Invoke-ProjectBuild "Peter/Peter" "Peter - Win32 Debug"
    Invoke-ProjectBuild "Peter/Peter" "Peter - Win32 Debug Optim"

    Invoke-ProjectBuild "Pov2Spr/Pov2Spr" "Pov2Spr - Win32 Release"
    Invoke-ProjectBuild "Pov2Spr/Pov2Spr" "Pov2Spr - Win32 Debug"    
}

# Setup needs generated bitmap resources from a DOS tool and is excluded.
Write-Host "==> All builds succeeded." -ForegroundColor Green
exit 0
