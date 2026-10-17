<#
.SYNOPSIS
    Builds every Peter project/configuration by running build-wine.sh inside the
    Wine + MSVC 6.0 container defined by Containerfile.wine.

.DESCRIPTION
    Reuses the image if it already exists (building it only when it is missing),
    starts a throwaway container with this repository mounted at /workspace,
    runs the build, and exits. Uses podman by default; docker and wslc work too.

    podman on Windows needs its VM running first: `podman machine start`.

.EXAMPLE
    ./build-wine.ps1
    Use the existing image, or build it first if it does not exist yet.

.EXAMPLE
    ./build-wine.ps1 -RebuildImage
    Force the image to be rebuilt before running the build.

.EXAMPLE
    ./build-wine.ps1 -Engine wslc
    Drive wslc instead of podman.

.EXAMPLE
    ./build-wine.ps1 -NoImageCheck
    Skip the image existence query and just run against the existing image.
#>
[CmdletBinding()]
param(
    [ValidateSet("podman", "docker", "wslc")]
    [string]$Engine = "podman",
    [string]$Image = "peter-wine",
    [switch]$RebuildImage,
    [switch]$NoImageCheck
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command $Engine -ErrorAction SilentlyContinue)) {
    throw "$Engine was not found on PATH."
}

$repo = $PSScriptRoot
$buildImage = [bool]$RebuildImage

if (-not $buildImage) {
    if ($NoImageCheck) {
        Write-Host "==> Skipping image check; assuming '$Image' exists."
    } else {
        Write-Host "==> Checking for image '$Image'..."
        & $Engine image inspect $Image *> $null
        if ($LASTEXITCODE -ne 0) {
            $buildImage = $true
        } else {
            Write-Host "==> Using existing image '$Image'."
        }
    }
}

if ($buildImage) {
    Write-Host "==> Building image '$Image' (this can take a while)..."
    & $Engine build -t $Image -f (Join-Path $repo "Containerfile.wine") $repo
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "==> Building the Peter sources in the container..."
& $Engine run -t --rm -v "${repo}:/workspace" $Image bash /workspace/build-wine.sh
$code = $LASTEXITCODE

if ($code -eq 0) {
    Write-Host "==> Build succeeded." -ForegroundColor Green
} else {
    Write-Host "==> Build failed (exit $code)." -ForegroundColor Red
}
exit $code
