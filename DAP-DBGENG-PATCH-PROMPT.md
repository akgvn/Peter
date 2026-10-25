# Agent prompt: fix local source resolution in dap-dbgeng

Implement the task below. Do not stop at proposing a solution: make the change,
build it, verify it against the actual debug adapter, and configure the provided
standalone repro workspace to use the verified build. Do not open an issue/PR,
push, or create a commit unless the user separately requests it.

## Goal

Make a VS Code `dbgeng` launch option open the real local source files instead
of trying to open build-machine paths such as `Z:\workspace\src\main.cpp`
stored in a PDB.
Fix the open-source DAP adapter, using the Windows debug engine's supported
source-file search API. The user wants to contribute the change upstream later.

Keep the repro executable and PDB unchanged for this fix. Do not introduce drive
aliases, junctions, source-path rewriting inside PDBs, or another executable
metadata workaround. Do not modify the installed extension's files.

## Inputs and independent workspace setup

This prompt is self-contained. Do not assume access to the application repository
where the problem was first investigated, its handoff documents, build scripts,
debug configuration, or temporary diagnostic tools.

You need two independent locations:

* **`<adapter-root>`:** a checkout of <https://github.com/svnscha/dap-dbgeng>.
* **`<repro-root>`:** the tiny standalone reproduction supplied by the user. The
  user plans to build it first and use it as the integration test case here.

The minimum integration input is a small C++ source file, its prebuilt original
x86 VC6 EXE and matching PDB, and the source/breakpoint instructions. The fuller
Microsoft-debugger repro may also include original-NB10 versus RSDS-reference
variants and build/verification scripts; those additional variants are not a
prerequisite for this source-resolution fix. Read its README and discover the
actual artifact paths
and source breakpoint markers; the layout below is an example, not a requirement
that those names already exist. Use the **original, unpatched NB10** variant for
this task. Do not assume that configurations intended for Microsoft's debugger
are already valid DbgEng configurations.

Confirm these inputs at the start. If the repro has not been supplied yet, ask
for its location or package; independent adapter-code inspection and test design
can proceed, but do not claim integration verification without a real test case.
Consuming the prebuilt repro should not require VC6, Wine, Podman, or the original
application's source. Rebuilding it is optional and follows its own instructions.

Read the adapter repository's `AGENTS.md`, if present, `CONTRIBUTING.md`,
`CLAUDE.md`, and applicable `.claude/rules/` files before editing its source.
Follow its current branch/contribution policy. The inspected instructions say
fixes branch from and target `develop`, not `main`.

The original investigation used extension/tag `v0.3.0`, with inspected source at
commit `8047f5d4ca4a58bab3930d903c04e80c693c8eec`. No fix was implemented during
that investigation. Check the actual checkout, version, and Git status; newer
upstream code may have changed. Preserve user changes, and do not assume a
pre-existing source checkout or branch is available on this machine.

## Working debugging setup and the specific failure

The original report involved `svnscha.vscode-dap-dbgeng` **0.3.0**. Its normal
installation location is:

```text
%USERPROFILE%\.vscode\extensions\svnscha.vscode-dap-dbgeng-0.3.0-win32-x64
```

It launches its bundled `bin/dap-dbgeng.exe`. Verify the installed version and
actual paths on this machine. An example standalone repro layout is:

```text
<repro-root>/src/main.cpp
<repro-root>/artifacts/original/nb10-repro.exe
<repro-root>/artifacts/original/nb10-repro.pdb
<repro-root>/artifacts/rsds-reference/nb10-repro.exe
<repro-root>/artifacts/rsds-reference/nb10-repro.pdb
```

The relevant target is an x86 VC6 application built with `/Z7 /Od` or `/Zi /Od`.
Its original linker emits a PDB 2.00 and an NB10 reference. Select a consolidated
`/PDBTYPE:CON` artifact from the supplied repro as the primary integration case.
The original example paths below are schematic; a matrix package may instead
use `artifacts/z7-con/original` or `artifacts/zi-con/original`.

Follow-up testing established the same NB10 discovery rejection in Microsoft's
`vsdbg` for both compiler switches, and successful typed locals after the
reference-only RSDS fix for both consolidated cases. CDB reads the consolidated
original NB10 cases directly. `/Zi /PDBTYPE:SEPT` adds a separate compatibility
problem: struct/pointer types were unreadable in DIA, vsdbg, and CDB even when
the compiler PDB was available; line breakpoints and basic integer types could
still work. `/Z7 SEPT` did not show that type failure in the tiny test.

Do not make the adapter's source-path fix depend on `/Z7`, and do not confuse
the separate-type-pool limitation with a source-file lookup regression. Confirm
behavior on the supplied repro rather than assuming every test result transfers.

For clarity, VC6's linker `/PDBTYPE:CON` consolidates type information from
compiler PDBs into the final linker PDB; `/PDBTYPE:SEPT` leaves it in separate
compiler type pools. The latter historically needs those additional PDBs and a
compatible reader. With `/Z7`, application types are embedded in the OBJ instead.
Neither linker choice selects NB10 versus RSDS or upgrades the PDB container.
The source-path fix should work independently of these type-storage choices;
use `CON` to avoid a separate type-inspection failure in the primary fixture.

A DbgEng launch configuration in the standalone repro could be:

```json
{
    "name": "NB10 repro (local DbgEng adapter)",
    "type": "dbgeng",
    "request": "launch",
    "program": "${workspaceFolder}/artifacts/original/nb10-repro.exe",
    "cwd": "${workspaceFolder}/artifacts/original",
    "stopAtEntry": true,
    "sources": ["${workspaceFolder}/src"],
    "symbolPath": ["${workspaceFolder}/artifacts/original"]
}
```

Here `${workspaceFolder}` is `<repro-root>`, not the adapter checkout. Adapt the
example to the supplied package. No pre-launch build task is needed to consume
prebuilt artifacts; do not add a hook that rewrites the original EXE's reference.

The reported failure is that the debugger starts and has source-line information,
but VS Code tries to open the compile-time path, for example
`Z:\workspace\src\main.cpp`, instead of the local `${workspaceFolder}/src/main.cpp`,
despite that directory being listed in `sources`.

Standalone WinDbg finds local files on Step Into when its source path is set.
The agent also verified x86 CDB `10.0.28000.2957` on the original NB10 executable:
private PDB symbols loaded, a source breakpoint was hit, and typed locals were
displayed. Thus this task concerns IDE source-file discovery, not PDB conversion.

## Root cause identified in the v0.3.0 source

* `src/service/dap_server_launch.cpp` reads `sources` and `symbolPath`.
* `src/debugger/debugger_session_symbols.cpp::set_source_path` sets `.srcpath`.
* `src/debugger/debugger_session_inspection.cpp::try_get_frame_source` uses
  `GetLineByOffset`, then returns the compile-time path unchanged.
* `src/util/debugger_session_dap_factory.cpp::create_source` copies that path into
  DAP `Source.path`.
* `src/service/dap_server_source.cpp` directly reads the supplied path and does
  not independently resolve a missing compile-time path.

The installed adapter does not implement a `sourceFileMap` launch option.
Do not add an ignored configuration property and call that a fix.

## Implementation requirements

1. Locate the equivalent code in the current checkout and keep the fix narrow.
   Resolve the path before it is emitted as a source location, preferably in a
   central location shared by stack/disassembly source reporting.
2. Use `IDebugSymbols::FindSourceFile`, or the appropriate wide-character variant,
   with the configured source search path. Request a full canonical path with
   `DEBUG_FIND_SOURCE_FULL_PATH`; consider `DEBUG_FIND_SOURCE_BEST_MATCH` for
   the engine's documented overlap/matching behavior.
3. On success, emit the resolved local path while preserving the source line.
   On lookup failure, keep the original path and source information; a missing
   source file must not destroy an otherwise valid stack frame.
4. Handle HRESULTs, buffer lengths, possible truncation, and null termination
   correctly. Avoid fixed-size silent truncation and stale data after a failed
   lookup. Follow the existing encoding conventions, addressing non-ASCII paths
   correctly if using the wide API.
5. Respect DbgEng's dispatcher-thread affinity. Keep engine calls on the existing
   engine thread and never log to stdout, which carries DAP traffic.
6. Do not hardcode `Z:\workspace`, a username, or the repro's directory structure.
   Use DbgEng's supported path/suffix matching rather than an ad hoc basename-only
   search that could silently choose the wrong same-named source file.
7. Inspect other source-bearing responses and source-content requests for
   consistency. Do not expand this into unrelated adapter refactoring.

Useful references:

* <https://learn.microsoft.com/windows-hardware/drivers/ddi/dbgeng/nf-dbgeng-idebugsymbols-findsourcefile>
* <https://github.com/svnscha/dap-dbgeng/blob/v0.3.0/src/debugger/debugger_session_inspection.cpp>
* The older adapter at <https://github.com/reedz/windbg-debug> already calls
  `FindSourceFileWide` with `BEST_MATCH | FULL_PATH` in
  `WinDbgWrapper.DoGetStackTrace`. It is a useful behavioral reference, not a
  reason to replace the newer adapter or copy unrelated implementation code.

## Regression tests

Follow the upstream test structure and add focused, meaningful coverage. Inspect
existing fixtures before choosing between unit and live-engine integration tests.
Cover at least:

* An already-accessible source path.
* A nonexistent build-machine absolute path resolved to a local file through a
  configured source directory.
* A genuinely missing source file: preserve the original path and line without
  failing the stack request.
* Paths containing spaces and correct path normalization.
* Multiple source directories / duplicate basenames where relevant, checking
  the chosen engine search semantics rather than inventing new precedence rules.

The important regression is the actual path delivered in a DAP source, not only
whether a helper returns a string. Avoid testing solely an implementation mirror.
If using a live DbgEng integration test, report whether it really ran or skipped.

Upstream regression tests must be self-contained: do not make the adapter's CI
depend on the user's repro package, a separate application repository, or a VC6
installation. Use the project's ordinary test facilities and temporary files or
an independently built test debuggee. The user-supplied VC6 repro is an additional
real-world integration check, not a required external CI dependency.

## Build and test the adapter

This is a Windows C++20 CMake/Ninja/vcpkg project. Use its existing
`scripts/With-DevEnv.ps1` helper, which selects the x64 Visual Studio environment.
Inspect the tools available on the current machine rather than assuming its
environment matches the original investigation. If Node/npm is unavailable,
the documented direct equivalents include:

```powershell
pwsh scripts/With-DevEnv.ps1 cmake --preset windows-x64
pwsh scripts/With-DevEnv.ps1 cmake --build --preset windows-debug
pwsh scripts/With-DevEnv.ps1 ctest --preset windows-debug
```

Also build/test Release using `windows-x64-release` and `windows-release`, as
required by upstream. Verify `VCPKG_ROOT`; use the environment-driven presets
instead of hardcoded Professional-edition installation paths. Building the
adapter requires modern MSVC and its dependencies even though consuming the
prebuilt test application does not require rebuilding that application.

Read the applicable upstream style rules. In the inspected checkout, the PCH
is the single include point for Windows/DbgEng/STL/common library headers,
handwritten targets use `/W4 /WX`, and formatting is Microsoft-style clang-format
with LF. Use the repository's formatting/check helpers where available. Avoid
editing generated protocol files or generated changelogs/version fields.

The adapter process is x64 even though the test application is x86. Match
`dbgeng.dll` to the adapter's architecture; do not select an x86 DLL merely
because the target is x86.
The SDK provides `Debuggers/x64/dbgeng.dll`.

## Deploy through the supported workspace override

Prefer a Release/static adapter build so deployment is self-contained, following
the project's Release preset. Verify the actual output path and copy the verified
executable, plus any required dependencies, into the standalone repro workspace:

```text
<repro-root>/.vscode/debuggers/dap-dbgeng.exe
```

Merge this into `<repro-root>/.vscode/settings.json` without overwriting other settings:

```json
{
    "dap-dbgeng.adapterPath": "${workspaceFolder}/.vscode/debuggers/dap-dbgeng.exe"
}
```

The installed extension's `out/adapter.js::resolveAdapterPath` explicitly supports
this setting and `${workspaceFolder}` substitution. It chooses an existing
override before the bundled executable. If the configured file is missing, it
falls back to the bundled adapter with an Output message. Confirm the actual
`Starting adapter:` path in the **dap-dbgeng** Output channel.

Do not replace the installed extension's executable or repackage its VSIX. Keep
the other debug launch options intact. Removing the setting should restore the
bundled adapter. Ignore generated binaries/dependency directories in Git.

## End-to-end acceptance criteria

Use the actual patched DAP adapter and the supplied standalone repro's original
NB10 executable/PDB. Follow the repro's README and source markers. A standalone
DIA enumeration is not sufficient verification. First reproduce the unresolved
source path using the bundled/unpatched adapter, then repeat with the patched
adapter and the same target artifacts/configuration.

Confirm that the recorded build-machine path is genuinely unavailable on the
test machine and that the corresponding file exists in a configured local
`sources` directory. Otherwise an already-accessible source path could conceal
the bug and create a false-positive verification result.

If the supplied package contains both `/Zi /PDBTYPE:CON` and
`/Z7 /PDBTYPE:CON` originals, run the acceptance checks against both. Treat any
known `/Zi SEPT` type-inspection failure as a separate compatibility result,
not a reason to change the PDB or weaken the source-path assertions.

Verify and record:

1. The running adapter is the newly built executable.
2. A test-program stack frame's DAP `Source.path` names the actual local source
   file under `<repro-root>`, rather than the missing compile-time path.
3. A breakpoint set using the local source path is verified and actually hit.
   Use the repro's executable-line markers and actual source; do not depend on
   historical application-specific filenames, line numbers, or variable names.
4. Step Into opens the correct local source, with source-content requests also
   working if used. Distinguish direct DAP verification from an actual UI check.
5. Locals/types remain usable, including the newer adapter's address/pointer
   presentation. The older `reznikdi.windbg-debug` extension worked but its locals
   rendering was inferior; preserving the newer adapter's inspection behavior matters.
6. Missing-source frames and ordinary same-machine paths still behave sensibly.

You may create a small DAP client if UI automation is unavailable. Do not assume
any diagnostic scripts from the original investigation exist. The adapter speaks
DAP over stdin/stdout; read its existing test/replay clients and actual event
ordering. A probe written for Microsoft's `vsdbg` is not interchangeable with
this adapter without adaptation. Treat direct DAP checks and manual VS Code
checks as different evidence, and report any UI steps that remain unverified.

Record target EXE/PDB hashes before and after testing. The path fix belongs in
the adapter; the original repro artifacts should remain byte-for-byte unchanged.

## Deliverables

* A focused upstream-ready source diff and regression tests in the adapter checkout.
* A built, verified local adapter and standalone repro workspace override.
* A reproducible patch file or equivalent reviewable diff, with its exact
  upstream base revision and build/deployment instructions. Save it in an
  agreed output location or the adapter checkout; no separate application
  repository is required to retain or apply the change.
* A concise verification report with the supplied repro's paths/markers,
  before-and-after DAP source paths, actual results, and override-removal
  instructions once an upstream release includes the fix. Keep this report in
  the adapter checkout or standalone repro package, not an assumed parent repo.
* A final summary listing modified files, source base/branch, test results/skips,
  adapter deployment path, and what was verified through DAP versus the UI.

Keep documentation paths anonymized (`<user>`, environment variables, or relative
paths). Prefer `uv run` for Python if available. Do not edit the supplied repro's
application source, EXE/PDB contents, unrelated user work, or global debugger/drive
configuration. Ask for a decision if the proper adapter fix requires a materially
broader design change.
