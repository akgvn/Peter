# Container builds and makefile exports

The image includes `export-mak.sh` and `build-project.sh` on `PATH`. Invoke them
directly with `podman run` (or `docker run`); no interactive shell is needed.
Mount the repository read-write at `/workspace` so exported files and build
outputs persist on the host. Keep the image's normal entrypoint for its Xvfb
display. Each invocation should use a separate container/Wine prefix: the
scripts stop Wine processes in their prefix when they finish.

## Build the image

From the repository directory in PowerShell:

```powershell
podman build -t peter-wine-alpine -f .\Containerfile.wine-alpine .
```

The scripts are also included when building the Debian `Containerfile.wine`.

## Export makefiles

Export all eight workspace projects:

```powershell
podman run --rm -v "${PWD}:/workspace" peter-wine-alpine export-mak.sh Peter250src/Peter.dsw
```

Or export one project:

```powershell
podman run --rm -v "${PWD}:/workspace" peter-wine-alpine export-mak.sh Peter250src/DelExe/DelExe.dsp
```

The script parses the workspace's project paths, confirms the export dialog,
checks that every expected `.mak` is nonempty and newer than the start of the
export, and closes the IDE. Existing `.mak` files are overwritten. The default
timeout is 60 seconds; increase it with `--timeout 120` if needed.

## Build a project

Build directly from a `.dsp` using `msdev`:

```powershell
podman run --rm -v "${PWD}:/workspace" peter-wine-alpine build-project.sh --rebuild Peter250src/DelExe/DelExe.dsp
```

Build an exported `.mak` using NMAKE:

```powershell
podman run --rm -v "${PWD}:/workspace" peter-wine-alpine build-project.sh --config Debug Peter250src/DelExe/DelExe.mak
```

Select a project-specific configuration:

```powershell
podman run --rm -v "${PWD}:/workspace" peter-wine-alpine build-project.sh --config "Gener - Win32 Release MINI" Peter250src/Gener/Gener.dsp
```

Select one project through the workspace:

```powershell
podman run --rm -v "${PWD}:/workspace" peter-wine-alpine build-project.sh --config "DelExe - Win32 Release" Peter250src/Peter.dsw
```

- Configuration defaults to `Release`. Project files accept either a short name
  such as `Debug`/`Release MINI` or the exact configuration name, case-sensitive.
- Workspaces accept `Release`/`Debug` for all projects, or an exact configuration
  name to select a project. Workspace builds include their normal dependencies.
- `--rebuild` cleans before building; `--clean` only cleans.
- `--timeout SECONDS` limits each build/clean command (default: 300 seconds).
- Build logs are printed to standard output; failures return a nonzero exit
  status. Usage errors return 2; timeouts return 124.
- NMAKE builds set `NO_EXTERNAL_DEPS=1` to skip stale checked-in `.dep` files,
  matching `build-wine.sh`. MSDEV builds use `/USEENV` for the image's tool paths.
- Building one project does not reproduce the full repository's build order.
  Use the existing `build-wine.ps1 -Image peter-wine-alpine` for its complete
  configuration matrix. The Setup installer still requires generated resources
  that the existing build script excludes.

Run either script with `--help` for its arguments. They can also be run from the
mounted repository with `bash /workspace/export-mak.sh ...` or
`bash /workspace/build-project.sh ...`, useful while editing the scripts before
rebuilding the image. On Linux/macOS, replace `${PWD}` with `$(pwd)` in the mount.
