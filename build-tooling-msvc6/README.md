# MSVC 6.0 container tooling

Run these PowerShell commands from the repository root. Mounting at `/workspace`
keeps exports and build outputs in the repository.

## Image

```powershell
podman build -t peter-wine -f .\build-tooling-msvc6\Containerfile.wine .\build-tooling-msvc6
```

## Full build

```powershell
.\build-wine.ps1
```

Builds 19 configurations directly from `.dsp` files in dependency order. Use
`-RebuildImage` to rebuild the image first. Setup is excluded because it needs
generated bitmap resources.

## NMAKE builds

```powershell
.\export-mak.ps1
.\build-wine.ps1 -UseNMake
```

Export after changing project files; builds do not export automatically.
The export overwrites all eight `.mak` files from `Peter250src/Peter.dsw`.

## Build a project

```powershell
podman run --rm -v "${PWD}:/workspace" peter-wine build-project.py --rebuild Peter250src/DelExe/DelExe.dsp
podman run --rm -v "${PWD}:/workspace" peter-wine build-project.py --config "DelExe - Win32 Debug" Peter250src/DelExe/DelExe.mak
```

`.dsp`/`.dsw` use MSDEV; `.mak` uses NMAKE. `--config` is passed verbatim. When
omitted, NMAKE uses the makefile's default and MSDEV uses `ALL - Release`.

Use a separate container per job; the helpers stop Wine processes on exit.
Both commands accept `--help` for options.

GitHub Actions runs the Wine build on pushes and pull requests. Successful runs
publish the executables as the `peter-msvc6` artifact (retained for 14 days).
