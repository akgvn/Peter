# Agent prompt: build a tiny NB10/PDB reproduction for Microsoft's debugger team

Create and verify a small, standalone reproduction of a Windows native
`cppvsdbg`/`vsdbg` symbol-discovery problem. Produce source, build instructions,
original and reference-patched EXE/PDB pairs, diagnostic evidence, and a compact
shareable archive. Do not open an issue, create a PR, push, or commit unless the
user separately requests it. The user will report the problem later.

## Goal and important distinction

The problem to reproduce belongs to Microsoft's native debugger, not to the
third-party `svnscha/dap-dbgeng` adapter. These are two separate investigations:

* Microsoft `cppvsdbg`/`vsdbg`: ignores the original VC6 EXE's **NB10 PDB reference**.
* Third-party DbgEng adapter: reads the symbols but returns an unresolved
  build-machine source path to VS Code. Do not make that source-path bug the
  subject of this reproduction.

The tiny program should remove Peter/Loader's custom runtime, libraries, large
application, and resources from the report. The key controlled comparison is:

```text
Original VC6-linked EXE + matching PDB 2.00 + NB10 reference
    -> actual vsdbg reports no debug information / no bound source breakpoint

Same EXE code/layout + same PDB bytes + equivalent RSDS reference
    -> actual vsdbg loads symbols, hits source breakpoint, displays typed locals
```

If the tiny program does not reproduce this on the installed debugger, report
that accurately and investigate the difference. Do not manufacture a mismatch,
claim an API-only check proves live debugging, or force the result to match the
earlier conclusion.

## Context to read

The current application workspace is the Peter repository. Read:

* `DEBUGGING-HANDOFF.md` for the experiments, environment, and existing evidence.
* `scripts/set-vc6-pdb-reference.ps1`, including its extensive comment-based help.
* `build-tooling-msvc6/Containerfile.wine` and the Wine tooling README.
* `.vscode/launch.json` for the Microsoft `cppvsdbg` configuration and source mapping.

Create this as a clearly isolated repro, for example under `repros/vsdbg-nb10/`,
with its own README/build scripts and artifact directories. It must be usable
independently after extraction, without building or running Loader. Do not edit
`NOTES.md`, Loader application code, or the production debug scripts to create it.
Preserve existing user changes and inspect Git status first.

## Confirmed facts from the original investigation

* Target: x86 executable built with VC6 `/Z7 /Od`, linked by linker 6.00 with `/DEBUG`.
* PDB file begins with `Microsoft C/C++ program database 2.00`.
* Original executable references that PDB through an NB10 record.
* Microsoft's DIA API can open the original EXE/PDB pair and read source lines,
  function records, local variables, and types.
* The actual installed `vsdbg` reported:
  `Binary was not built with debug information.`
* Replacing the EXE's reference with RSDS made the actual debugger load that
  unchanged PDB, bind and hit a source breakpoint, and display typed locals.
* Correcting NB10's PDB path and giving the record a mapped RVA did not fix the
  original Loader case. An RSDS record outside the mapped image did work.
* x86 CDB `10.0.28000.2957` was verified on the original NB10 executable with
  private PDB symbols, a hit source breakpoint, and typed locals. Standalone
  WinDbg also worked; setting its source path enabled automatic source loading.

Observed versions, to be rechecked and reported for the new reproduction:

* Microsoft C/C++ extension: `ms-vscode.cpptools-1.34.4-win32-x64`.
* Bundled `vsdbg`: `17.13.20115.1` according to its debugger telemetry.
* VS Code: `1.143.1`, x64.
* Windows build: `10.0.26200`.

These observations do not imply every old PDB or every debugger version behaves
the same way. Record exactly which versions reproduce the tiny case.

## Minimal test program

Prefer one small C++ source file, roughly 20-40 lines, compatible with VC6:

* A struct with two integer fields.
* A pointer to an instance of that struct.
* Two or three integer locals with deterministic values.
* One ordinary helper function called from a conventional `int main()`.
* Executable-line markers for a breakpoint in main after inputs are initialized,
  a breakpoint in the helper after its result is initialized, and a point after
  returning to main.
* A deterministic zero exit code when the computation is correct.

Avoid a GUI, Peter resources, custom entry points, STL, templates, external
libraries, input prompts, and unnecessary threading. `/Od` should preserve the
function call and locals; avoid depending on a compiler attribute introduced
after VC6. Choose breakpoint lines from source markers rather than hardcoding
Loader's old line 483.

Prefer conventional VC6 static CRT linkage (`/MT`) so recipients do not need an
old debug CRT DLL. Debug information and optimization settings are independent
of that runtime choice. For the linker use `/DEBUG /INCREMENTAL:NO` and consider
`/PDBTYPE:CON` to produce a self-contained final PDB. Avoid relying on a separate
compiler `vc60.pdb`, which would add a second symbol-discovery problem.

## Build with the actual VC6 toolchain

The available Podman image is normally `peter-wine`. It contains VC6 at
`C:\msvc600\VC98` with Wine tool paths, INCLUDE, and LIB configured. Original
libraries also exist locally under `../MSVC600-master/VC98/Lib`.

Prefer the existing Wine image. Mount the standalone repro root at `/workspace`
so its recorded source paths are generic, such as `Z:\workspace\src\main.cpp`,
rather than private host account paths. This also simplifies the source mapping
when Microsoft extracts the archive elsewhere.

Build using Wine's VC6 `cl.exe` and `link.exe`, not an unqualified host `cl` that
might resolve to modern MSVC. A suitable starting point is compiling with
`/Z7 /Od /MT` and linking the resulting OBJ with VC6's `/DEBUG` options. Verify
the commands and actual outputs rather than merely relying on their names.

The build helper should:

1. Accept a configurable image/toolchain location as appropriate.
2. Produce a clean, fresh original executable and matching PDB.
3. Fail on build errors and preserve a useful build log with compiler/linker versions.
4. Inspect the resulting PE32 header to confirm linker version 6.00 and NB10.
5. Confirm the database's PDB 2.00 header.
6. Build only this tiny program, not the Peter configuration matrix.

No modern linker is needed for the primary reproduction. A modern-linker positive
control is optional and must not replace the reference-only controlled test.

## Produce paired artifacts without relinking them independently

Use the same basename in each variant, for example:

```text
src/main.cpp
artifacts/original/nb10-repro.exe
artifacts/original/nb10-repro.pdb
artifacts/rsds-reference/nb10-repro.exe
artifacts/rsds-reference/nb10-repro.pdb
```

Build the original once, then copy the EXE and PDB to the second directory and
patch only that EXE. Do not rebuild each variant separately: then differing
symbols, ages, timestamps, or code could confound the comparison.

The existing `scripts/set-vc6-pdb-reference.ps1` implements the reference-only
transformation. Include an appropriately attributed standalone copy in the repro
or an equivalent narrowly scoped helper so the extracted package does not depend
on its parent repository. Keep its behavior consistent with the tested logic:

* NB10 layout: magic at 0, legacy offset at 4, PDB timestamp at 8, age at 12,
  null-terminated PDB name/path at 16.
* RSDS layout: magic at 0, 16-byte GUID at 4, age at 20, null-terminated path at 24.
* For the tested PDB 2.00 reader, GUID Data1 is the original PDB timestamp and
  the remaining twelve bytes are zero. Copy the original age unchanged.
* This is the PDB's identity, not the EXE timestamp, file modification time,
  or a newly generated random GUID.
* Use a same-basename PDB filename so the larger RSDS header fits within the
  original record allocation. Update `SizeOfData` and clear unused bytes.
* Keep executable code, entry-point RVA, section layout, and length unchanged,
  as well as every byte of the PDB. Fail rather than overwrite beyond the
  available allocation. Verify idempotence.

Add a useful negative control if practical: a third directory containing a copy
with **NB10 retained but the PDB path corrected/shortened**. The purpose is to
show that changing only the path is insufficient, rather than attributing an
ordinary search-path repair to the magic change. Document any additional
metadata changes precisely. A mapped-RVA control is optional, not a requirement
to grow this into a PE editing toolkit.

## VS Code launch configurations for the recipient

Provide standalone `.vscode/launch.json` configurations using **`cppvsdbg`** for
the original, RSDS-reference, and any negative-control variants.

* Use `${workspaceFolder}` paths and explicit variant-specific `symbolSearchPath`.
* Map the generic Wine build source root to the extracted local repro root with
  `sourceFileMap`. Use the same mapping for all variants.
* Do not use third-party `dbgeng` or legacy `windbg` debug types for the primary report.
* Enable useful module/engine diagnostics, keeping output understandable.
* Ensure a recipient can inspect prebuilt artifacts without a `preLaunchTask`
  that rebuilds, patches the original, or requires the unavailable VC6 compiler.
* Explain how to set the marked source breakpoints and inspect the struct,
  pointer, integer locals, and helper call stack.

Keep matching PDBs beside their respective EXEs. Demonstrate that symbol lookup
is correct rather than relying only on the embedded Wine path.

## Verification matrix: actual debugger, not only DIA

Run and record the behavior on the installed backend:

| Variant/tool | Result to investigate and verify |
| --- | --- |
| Original EXE/PDB through DIA | Database is readable; enumerate the test function, marked source lines, and local types. |
| Original NB10 through actual vsdbg | Reproduce the reported rejection, unbound source breakpoint, and module status; do not assume it fails without running it. |
| NB10 with corrected PDB path, if created | Determine whether it still rejects the reference despite valid symbol search paths. |
| Equivalent RSDS through actual vsdbg | Module reports symbols loaded; marked breakpoint binds and is hit; source-resolved stack and correctly typed/initialized locals are available. |
| Original NB10 through CDB/WinDbg | Confirm an independent backend loads symbols and hits a source breakpoint with typed locals. |

Do not enable a force-load-any-symbols or ignore-mismatch option. The identity
must actually match. A public function name or a successful process launch is
not enough evidence of usable source debugging.

Use VS Code's real debugger where practical. A direct DAP test against the
bundled `vsdbg.exe` is also useful if its provenance is documented. Record the
difference between DAP verification and actual UI testing.

Previous diagnostics are under `%LOCALAPPDATA%\Temp\opencode`:

* `probe-loader-vsdbg.py` / `vsdbg-sign.js`: direct installed-adapter probe using
  the installed VS Code runtime/handshake module. Copy/adapt it for the new
  executable, source markers, and expected locals; it is currently Loader-specific.
* `verify_loader_pdb.py`: DIA inspection using `comtypes` and a directly loaded
  DIA class factory. It can use the DLL bundled with the C/C++ extension and does
  not require COM registration. Again, it is not a live debugger test.
* `verify-vc6-reference-patch.py`: useful model for byte-diff and idempotence
  checks, but it rebuilds Loader and must not be run unmodified for this repro.

Recheck hardcoded paths and extension versions before reusing any diagnostic.
Use `uv run` for Python locally. Do not include Microsoft debugger binaries,
handshake modules, or the VC6 toolchain in the shareable archive.

## Evidence and package requirements

Produce a README that another engineer can follow after extracting the archive.
Include:

* A concise problem statement, expected behavior, actual observed behavior,
  and exact environment/compiler/linker/debugger versions.
* The tiny source and original build/patch commands, including Wine prerequisites
  only for rebuilding, not for consuming the prebuilt Windows reproduction.
* Instructions for both VS Code variants and the independent CDB/WinDbg check.
  CDB lives under the SDK's `Debuggers/x86/cdb.exe`; use `-lines`, symbol paths,
  source paths, a marked source breakpoint, and `dv /t`.
* Header summaries of the PE reference and PDB magic, with their identifier/age.
* SHA-256 hashes proving the variant PDB files are identical, and a byte-diff
  report proving the EXEs differ only in the reference allocation and its size.
* Sanitized debugger logs showing module status, breakpoint verification/hits,
  stack source positions, and typed locals, plus failures for the original case.
* A ready-to-paste issue draft, distinguishing the proven discovery failure from
  guesses about the private backend's internal implementation.

Keep the ZIP small: source, relevant scripts/configuration, the matched EXE/PDB
pairs, and concise evidence. Exclude unrelated application data, OBJs, caches,
toolchains, huge system-symbol downloads, and raw private logs. Keep build paths
generic where possible and sanitize human-readable host account paths using
`<user>` or `<repro-root>` without changing the identity evidence or tested artifacts.
Raw local logs may be retained outside the shareable archive when needed.

The intended public reporting entry point is:

* <https://github.com/microsoft/vscode-cpptools>
* <https://github.com/microsoft/vscode-cpptools/issues/new?template=2_debugger.yml>

Suggested title: **cppvsdbg ignores VC6 NB10 PDB references although the matching
PDB is readable by DIA**. Do not actually file it; the user will do that later.

## Completion criteria

Deliver the isolated source project, reproducible build/reference-patch tooling,
matched artifacts, sanitized evidence, standalone launch configurations, issue
draft, and shareable ZIP. Verify the archive contains what its README references.

Summarize the real result of every matrix row, any unverified UI steps, tool
versions, and the artifact/archive locations. If the small conventional program
does not reproduce the original Loader behavior, stop claiming the case is
isolated: explain the difference and the smallest further experiment needed.
