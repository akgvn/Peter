# Loader debugging: investigation and fresh-agent handoff

Recorded 2026-10-25. This document captures the investigation, including failed
experiments and corrections to earlier conclusions. The [README](README.md)
describes the supported workflow. Implementation details are also documented in
[`scripts/set-vc6-pdb-reference.py`](scripts/set-vc6-pdb-reference.py).

## Contents

1. [Current state and verified workflow](#1-executive-summary-and-current-state)
2. [Files, environment, and maintenance instructions](#2-files-environment-and-instructions-for-the-next-agent)
3. [Why the original executable fails](#3-why-the-unmodified-vc6-executable-fails-in-vs-code)
4. [NB10, RSDS, and PDB versions](#4-nb10-rsds-codeview-and-pdb-versions)
5. [Why the metadata patch works](#5-why-the-reference-patching-script-works)
6. [/Z7 and modern linking](#6-what-z7-changes-and-why-modern-linkexe-also-worked)
7. [Experiments and corrected conclusions](#7-experiments-failures-and-corrected-conclusions)
8. [vsdbg and the extension source](#8-vsdbg-the-vs-code-extension-and-where-the-problem-lives)
9. [Concord plug-ins](#9-concord-debugger-plug-ins)
10. [Alternative debugger backends](#10-could-another-debugger-backend-solve-it)
11. [Other implementation options](#11-other-implementation-options)
12. [Expert questions](#12-questions-a-domain-expert-should-ask)
13. [Reporting to Microsoft](#13-reporting-this-to-microsoft)
14. [Reproduction and evidence](#14-reproducing-the-investigation-and-locating-evidence)
15. [References](#15-references)

## 1. Executive summary and current state

**VC6's PDB is readable. The installed VS Code native debugger fails to recognize
the executable's original `NB10` reference to that PDB.** Replacing only that
reference with an equivalent `RSDS` record makes source debugging work with the
same PDB. It does not require recompilation with a modern compiler, a modern
linker, or a local Visual Studio installation.

The current pipeline is:

```text
F5: Loader (Wine build, Windows debug)
  -> tasks.json: Build Loader (Wine)
  -> build-loader-debug.ps1
     -> build-wine.ps1
        -> Podman / Wine / MSVC6 compiler with /Z7 and /Od
        -> MSVC6 linker with /DEBUG
        -> Peter250src/Loader/Debug/Peter.exe + Peter.pdb
     -> uv run --no-project python scripts/set-vc6-pdb-reference.py
        -> replace the EXE's NB10 reference with RSDS, keeping the PDB intact
  -> cppvsdbg / vsdbg on the Windows host
```

Local prerequisites: PowerShell 7, uv for the Python reference helper, Podman
with its machine running, and Microsoft VS Code with the Microsoft C/C++
extension. The Wine image supplies the compiler, linker, and libraries. The
patcher uses only Python's standard library; DIA is still an investigation tool,
not a build dependency.

```powershell
podman machine start
./build-loader-debug.ps1
# Explicit clean rebuild:
./build-loader-debug.ps1 -Rebuild
```

**Verified with the actual debugger**, not just a symbol-file API:

* Module status: `Symbols loaded.`
* A breakpoint in `Peter250src/Loader/Main.cpp:483` was verified and hit.
* The stack showed `WinMainCRTStartup()` at that source line.
* Locals included `acp: int`, `file: CFileMap`, and `systime: _SYSTEMTIME`.
* A byte comparison confirmed that the patch preserved the PDB, EXE length,
  section layout, and all EXE bytes outside the reference allocation and its
  `SizeOfData` field. Applying the patch twice produced identical bytes.

This establishes this tested workflow, not universal compatibility with every
VC6 program, debugger release, or debugging feature.

## 2. Files, environment, and instructions for the next agent

| Location | Purpose |
| --- | --- |
| [`build-loader-debug.ps1`](build-loader-debug.ps1) | Calls the Wine build, then patches the PDB reference. Detects OBJ files older than the DSP and requests a rebuild so changed compiler options take effect. |
| [`build-wine.ps1`](build-wine.ps1) | Runs builds through Podman. Currently selects `Loader - Win32 Debug`; most other configurations are commented out. Supports `-Rebuild`. |
| [`Peter250src/Loader/Peter.dsp`](Peter250src/Loader/Peter.dsp) | VC6 project. Its effective Debug compiler options contain `/Z7 /Od`; `/Gm` was removed when switching from `/Zi`. |
| [`scripts/set-vc6-pdb-reference.py`](scripts/set-vc6-pdb-reference.py) | Dependency-free Python PE32 metadata adjustment, explained below. |
| [`.vscode/launch.json`](.vscode/launch.json) | Uses `cppvsdbg`, launches `Debug/Peter.exe`, searches `Debug` for symbols, maps `Z:\workspace` to the checkout. |
| [`.vscode/tasks.json`](.vscode/tasks.json) | Runs the debug-build wrapper with PowerShell 7 before launch. |
| [`devenv-32.ps1`](devenv-32.ps1) | Existing helper for local modern MSVC tools. Not used by the current debug workflow. |
| `../MSVC600-master/VC98/Lib` | Original VC6 libraries on this machine. Copies also exist in the Wine image. |
| `../vscode-cpptools` | Local extension-source checkout inspected during this investigation. |

Observed environment:

* Workspace: `C:\Users\<user>\repos\Peter`.
* VS Code: `1.143.1`, x64, commit `e646868227c3e3a9e3f24277c8c7220be42c0be7`.
* Installed C/C++ extension: `ms-vscode.cpptools-1.34.4-win32-x64`.
* Bundled `vsdbg`: `17.13.20115.1`, as reported in debugger telemetry.
* Windows version reported by the debugger: `10.0.26200`.
* Local extension-source checkout inspected at commit `692fb60a`.
* Peter baseline at documentation time: `05bdc3d` (`Use the MSVC6 linker`).

Paths containing `<user>` are anonymized examples; substitute your Windows
account name when using them.

User preferences and important maintenance details:

* Do not put this material in, or otherwise edit, `NOTES.md`.
* Keep normal setup instructions in the README focused on the working path;
  failed experiments belong in this handoff.
* Use `uv run` for Python commands on this machine.
* Preserve CRLF in VC6 DSP files. Mixed line endings caused MSDEV to misparse a
  compiler-option line during an intermediate experiment and generate `.sbr`
  source-browser artifacts. Those artifacts were removed and the line endings fixed.
* Preserve user application-code changes. No Loader runtime-code change was
  needed for the symbol-discovery fix.
* `build-wine.ps1` no longer ends in `exit 0`; call it directly rather than
  reintroducing a child PowerShell process just to accommodate that old behavior.
* If a future experiment needs local modern MSVC, reuse `devenv-32.ps1`.

## 3. Why the unmodified VC6 executable fails in VS Code

Debugging requires several distinct operations:

1. Discover a symbol reference in the executable.
2. Locate the symbol file and validate that it matches the executable.
3. Read its symbols, types, and source lines.
4. Bind breakpoints and evaluate variables in a running process.

The installed `vsdbg` reports the original VC6 EXE as:

```text
Binary was not built with debug information.
```

This message is misleading here: the EXE contains an `IMAGE_DEBUG_TYPE_CODEVIEW`
directory entry referencing a valid PDB, and DIA can read that EXE/PDB pair.

The decisive experiment changed only the reference from `NB10` to `RSDS`.
The debugger then loaded the unchanged PDB and performed source debugging.
An additional experiment gave an `NB10` record a proper mapped RVA and corrected
absolute PDB path; that still failed. An `RSDS` record outside the mapped image
worked. Thus this is not explained merely by Wine's path or the debug payload
having `AddressOfRawData == 0`.

The evidence isolates the rejection to the native debugger stack's handling of
the legacy reference. We do not have its private source, so we cannot identify
the exact internal function or claim the behavior is intentional.

## 4. NB10, RSDS, CodeView, and PDB versions

### Four different layers that must not be conflated

* **PE** is the executable/container format. Its debug directory describes debug data.
* **The CodeView PDB-reference record in the EXE** identifies an external PDB.
  `NB10` and `RSDS` are four-byte ASCII signatures selecting this record's layout.
* **PDB/MSF** is the database and multi-stream container on disk, containing
  symbol/type records, module information, source lines, and lookup structures.
* **CodeView symbol/type/line encodings** also occur inside OBJs and PDB streams.
  Compatibility with one of these layers does not establish compatibility with all.

### PDB-reference layouts

Offsets and sizes are in bytes. Integer fields are little-endian.

| Offset | NB10 field | Size |
| --- | --- | --- |
| 0 | ASCII `NB10` | 4 |
| 4 | Legacy offset, unused for this external PDB reference | 4 |
| 8 | PDB timestamp signature | 4 |
| 12 | PDB age | 4 |
| 16 | Null-terminated PDB path | Variable |

| Offset | RSDS field | Size |
| --- | --- | --- |
| 0 | ASCII `RSDS` | 4 |
| 4 | PDB GUID | 16 |
| 20 | PDB age | 4 |
| 24 | Null-terminated PDB path | Variable |

The timestamp is an identifier, not a value to replace with the EXE timestamp
or filesystem modification time. The age is a database revision counter, not
a duration. Identifier and age must match; a matching filename alone is insufficient.

### PDB 2.00 versus newer PDBs

VC6 emits the older PDB 2.00 format, identifiable by a file header beginning with
`Microsoft C/C++ program database 2.00`. Its normal executable reference uses a
timestamp signature plus age (`NB10`).

The later PDB format commonly called PDB 7.0 uses the MSF 7.00 container, whose
header begins `Microsoft C/C++ MSF 7.00`. Its normal executable reference uses a
GUID plus age (`RSDS`). Container/directory layouts and internal stream/record
versions evolved as well; the difference is not just the EXE's four-byte magic.
These versions are not synonymous with 32-bit and 64-bit programs.

**Our patched EXE contains RSDS but its PDB remains PDB 2.00.** That combination
works because this reader can expose the legacy PDB's identity as a GUID and
read its older contents. It is a tested compatibility bridge, not a conversion
to PDB 7.0 or a guarantee for every consumer of RSDS.

## 5. Why the reference-patching script works

For the tested PDB 2.00 files, DIA exposes the legacy identifier as:

```text
GUID.Data1 = original 32-bit PDB timestamp signature
GUID.Data2 = 0
GUID.Data3 = 0
GUID.Data4 = eight zero bytes
age        = original PDB age
```

The script uses that exact representation; it does not assign a random GUID
or force the debugger to ignore a symbol mismatch.

Implementation:

1. Read the DOS header's `e_lfanew`, validate the PE signature and PE32 optional header.
2. Read data-directory entry 6 (`IMAGE_DIRECTORY_ENTRY_DEBUG`).
3. Translate its RVA into a file offset through the containing section.
4. Walk the 28-byte `IMAGE_DEBUG_DIRECTORY` entries to find type 2 (CodeView).
5. Follow `PointerToRawData` to the reference. The VC6 payload is outside the
   mapped sections, so its raw file offset matters even if its data RVA is zero.
6. Build RSDS using the timestamp-derived GUID and preserved age.
7. Use `Peter.pdb` as the filename, instead of the absolute Wine path. The new
   header is eight bytes larger, but the shorter path makes the full record fit.
   For `Peter.pdb`, the new record is 24 + 10 = 34 bytes including the null terminator.
8. Replace it in its existing allocation, zero the unused tail, and update `SizeOfData`.

No section is added, no code is moved, and the PDB is not rewritten. An already
RSDS-referencing executable is left alone. A new VC6 link recreates NB10, so the
wrapper runs the script after every successful build.

PDB lookup and source lookup are separate: `symbolSearchPath` helps locate the
PDB; `sourceFileMap` translates `Z:\workspace` paths stored in that PDB. The path
shortening is useful, but correcting a path alone did not fix the NB10 rejection.

### Python port

The helper was originally implemented in PowerShell and has been replaced by
the Python script linked above. `build-loader-debug.ps1` now invokes it with uv
and propagates a nonzero exit code. Direct usage:

```powershell
uv run --no-project python scripts/set-vc6-pdb-reference.py path/to/program.exe
```

The Python port validates file ranges and PE32 headers before modifying bytes.
It returns already-RSDS images without rewriting the file. Its tests cover
payloads outside mapped sections, identity/age preservation, all unrelated bytes,
UTF-8 names, malformed input, insufficient space, and a no-write second run.
Before removing the PowerShell implementation, byte-for-byte comparisons on
fresh Loader `/Z7` and tiny `/Zi CON` outputs confirmed identical patched EXEs
and unchanged PDBs. The updated wrapper and Python helper were also verified
with the actual installed vsdbg: symbols loaded, `Main.cpp:483` was hit, and
typed locals were displayed. The historical temporary diagnostics that invoked
the old PowerShell filename need their invocation updated before reuse.

## 6. What /Z7 changes, and why modern link.exe also worked

`/Zi` stores compiler debug information in a compiler PDB, traditionally
`vc60.pdb` for VC6. `/Z7` embeds it in the OBJ instead. With `/Z7`, a linker can
consume those symbols without needing to open the old compiler PDB. `/Od`
separately disables compiler optimization. `/Z7` does not itself choose the
final PDB version or the EXE's reference format; the linker does that. The name
"C7 Compatible" does not mean "PDB 7.0".

VC6's linker `/PDBTYPE:CON` (consolidate) copies type information from available
compiler PDBs into the final linker PDB. `/PDBTYPE:SEPT` (separate types) leaves
those pools separate, requiring the additional compiler PDBs and a reader that
supports that older organization. The EXE still identifies the final linker PDB.
With `/Z7` inputs the linker can read embedded OBJ types directly; mixed inputs
or libraries compiled with `/Zi` can still introduce compiler-PDB dependencies.
See [the detailed CON/SEPT explanation](VC6-DEBUG-FORMAT-MATRIX.md#what-con-and-sept-mean)
for the artifact lifecycle and why this does not change NB10/RSDS or the PDB
container version.

The modern Microsoft linker accepted the VC6 `/Z7` objects and produced a modern
PDB and an ordinary RSDS reference. That provides the symbol discovery path
expected by `cppvsdbg` while making the symbols available through the modern
PDB reader. Initial checks of that route used DIA; the final reference-only
solution received the stronger actual-debugger breakpoint-and-locals test.

The modern-link route was removed from the current build because the reference
patch achieves our goal using the original compiler and linker. Modern relinking
also changes more than debug metadata: ASLR/relocations, DEP compatibility,
Terminal Server awareness, file alignment, subsystem version, and code layout
differed in the observed outputs. See the [README comparison](README.md#vc6-vs-modern-msvc-linker-defaults-loader).

### Follow-up: /Zi is also usable with consolidated types

The compiler-storage question was later tested with a separate 21-line,
static-CRT console program using VC6 compiler `12.00.8804` and linker `6.00.8447`.
See [the full measured matrix](VC6-DEBUG-FORMAT-MATRIX.md) for commands, controls,
and evidence locations.

* `/Z7 CON`, `/Z7 SEPT`, and `/Zi CON` all produced NB10 outputs rejected by
  actual vsdbg. The equivalent RSDS-reference copies loaded, hit source
  breakpoints, and exposed `Sample`, `Sample *`, integer locals, and struct members.
* `/Zi CON` retained those types when only the EXE and final PDB were copied
  into an isolated directory without the compiler PDB or an accessible Wine
  compiler-PDB path. Thus `/Z7` is not inherently required for this workaround.
* `/Zi SEPT` also produced NB10 rejected by vsdbg. Its RSDS-reference copy loaded
  and hit the line breakpoint, but the struct/pointer locals failed evaluation;
  integers remained readable. DIA and CDB independently showed the missing types.
* Supplying the compiler PDB beside the separate-types executable, or in a
  supplementary build at its actual recorded host-visible path, did not repair
  those user-defined types in the tested readers. This matches the historical
  separate-type-pool limitation in archived Microsoft KB318135, not merely a
  wrong-path problem.

The primary Microsoft reproduction must therefore include both `/Zi CON` and
`/Z7 CON`. Keep `SEPT` as a secondary diagnostic; do not let its type-pool
compatibility issue obscure the NB10 discovery failure. The DbgEng source-path
contribution should likewise use a consolidated original-NB10 case as its
primary fixture. All four original test images had identical `.text` bytes.

## 7. Experiments, failures, and corrected conclusions

| Experiment | Observed result | What it establishes |
| --- | --- | --- |
| Original `/Zi` VC6 build launched in VS Code | User reported missing symbols. | The starting configuration did not provide usable source debugging; this alone did not isolate the cause. |
| `/Z7` + original VC6 linker, no metadata patch | DIA loaded the EXE/PDB and found lines/types/locals; actual `vsdbg` rejected it as having no debug information. | Readable PDB contents are insufficient if executable-side discovery rejects NB10. |
| NB10 with a mapped data RVA and corrected absolute PDB path | Actual `vsdbg` still rejected it. | Merely fixing file/memory location or the Wine path was insufficient. |
| RSDS referencing the unchanged VC6 PDB, both mapped and raw-file-only variants | Actual `vsdbg` loaded symbols, verified breakpoints, and displayed locals. | A metadata-only bridge works; remapping the payload is unnecessary for this debugger. |
| `/Z7` + modern Microsoft `link.exe` | Produced modern EXE/PDB; DIA read source lines and locals. | Modern linking can consume these embedded symbols, but needs local tooling and changes image defaults/layout. |
| `cv2pdb` 0.54 on the original PDB-referencing EXE | `no debug entries found`. | It did not directly convert this external VC6 PDB setup. |
| VC6 `/PDB:NONE` to embed CodeView, then `cv2pdb` 0.54 | `unsupported field entry`, also observed after trying `/Z7`. | The converter did not handle Loader's embedded symbol/type records. This is not a general verdict on its DMD/DMC/DWARF use cases. |
| Zig 0.16.0 `zig lld-link`, original VC6 libraries | With `/SAFESEH:NO`, linked an EXE/PDB but warned that `.debug$S` and `.debug$T` had unrecognized magic `0x2`. DIA found zero function records and no `Main.cpp`. | Resolving code/libraries does not mean preserving old CodeView debug records. |
| GNU ld 2.45.1 (`C:\mingw32`) and 2.46 (`C:\msys64\mingw64`), original VC6 libraries, `-m i386pe` | Without PDB generation: produced PE files, with unsupported `.drectve` warnings including the CRT section merge. With `--pdb`: both crashed with `0xC0000005`, leaving empty PDBs/incomplete EXEs. | Those versions did not provide the required PDB pipeline for these inputs. Non-PDB output was not runtime-qualified. |
| GDB on GNU-linked output | Could not resolve `Main.cpp` source lines; displayed unusable/misinterpreted symbol information. | This installed GDB did not rescue source debugging through that route. |

Two important corrections to the conversation:

* The earlier suggestion that PDB 2.00 inherently required conversion was wrong.
  DIA and the patched-reference `vsdbg` session both read the existing PDB.
* Calling a successful DIA test proof of working VS Code debugging was wrong.
  Actual module status, breakpoint binding/hits, and variable evaluation are the
  acceptance criteria. Do not repeat that inference when testing another backend.

## 8. vsdbg, the VS Code extension, and where the problem lives

`vsdbg.exe` is Microsoft's native debug-adapter process used by the extension's
Windows-only `cppvsdbg` configuration. It speaks Debug Adapter Protocol (DAP)
to VS Code and uses the Visual Studio native debugging stack, including Concord.
It is proprietary and is not implemented by the extension's public TypeScript.

```text
VS Code UI / breakpoint and variable views
    -> public C/C++ extension: configuration and adapter selection
    -> DAP requests to vsdbg.exe
    -> native debugger stack: executable inspection, symbols, execution control
    -> PDB reader / DIA and debug information
```

DIA is Microsoft's Debug Interface Access API. Our verification used it to read
symbols; it is not a debug adapter and does not by itself run a process, bind a
live breakpoint, or establish that `vsdbg` accepts the executable.

The local `../vscode-cpptools` source confirms the separation:

* `Extension/src/Debugger/extension.ts`, around lines 83-85, registers the factories.
* `Extension/src/Debugger/debugAdapterDescriptorFactory.ts`, around lines 55-75,
  launches `debugAdapters/vsdbg/bin/vsdbg.exe` with `--interpreter=vscode` and
  `--extConfigDir=%USERPROFILE%\.cppvsdbg\extensions`.
* `Extension/src/Debugger/configurationProvider.ts`, around lines 237-275,
  handles configuration, console compatibility, environment, and source mappings.
* No NB10/RSDS parsing or the reported rejection message was found in that source.

More decisively, the rejection and successful RSDS counterpart were reproduced
by talking directly to `vsdbg.exe`, without running that TypeScript code.
The exact internal rejecting component remains unknown because its source is private.

The public extension could automate preprocessing, or launch a wrapper, but
that would relocate our workaround rather than fix native NB10 handling.

`cppdbg` is a different debug type: it uses OpenDebugAD7/MIEngine to communicate
with GDB or LLDB over MI. Changing `cppvsdbg` to `cppdbg` does not make Microsoft's
PDB reader available to those backends. IntelliSense is also separate from
debug-symbol loading.

## 9. Concord debugger plug-ins

Concord is Visual Studio's extensible debugging engine, first shipped in
Visual Studio 2012. Its plug-ins are debugger components, such as language
expression evaluators and custom visualization components. They are distinct
from VS Code JavaScript/TypeScript extensions and from PDB-conversion utilities.

Microsoft documents loading Concord extensions in `cppvsdbg` using `.link`
files under `%USERPROFILE%\.cppvsdbg\extensions`. The adapter factory above
already supplies the matching extension-configuration directory. Supporting
components use the Concord SDK/API and appropriate registration/configuration.
For example, documented `codeViewCompilerIds` configuration maps language IDs;
it is not a switch that enables the NB10 record format.

A custom native-debugger component might supply another solution, but **we have
not established that supported hooks can intercept and repair this exact
symbol-discovery step**. No such plug-in was implemented or tested. The fact
that `vsdbg` is closed source does not make all extension-based solutions
impossible; neither does the existence of a plug-in system prove this one is easy.

### Follow-up API investigation: what is actually exposed

The public documentation and the public API of the installed adapter's
`Microsoft.VisualStudio.Debugger.Engine.dll` were inspected. This was API
inspection using .NET reflection, not a working plug-in experiment.

| API | Relevance and limitation |
| --- | --- |
| `IDkmModuleInstanceLoadNotification.OnModuleInstanceLoad` | Runs even when symbols are missing and the process is suspended. A plug-in can inspect the module and parse its on-disk NB10 record. The callback receives an already-created module instance; it does not return a replacement symbol identity. |
| `DkmPdbFileId.Create(SymbolProviderId, Mvid, Age, PdbName)` | Can represent the timestamp-derived GUID, age, and PDB path that we need. Creating this object does not attach it to an existing native module or open a PDB. |
| `DkmModuleInstance.SymbolFileId` | Read-only in both the documentation and the installed assembly (`CanWrite == false`). No public setter or native PE/CodeView parser-override interface was found in the inspected surface. This is the obstacle to a small identity-translation plug-in that reuses the built-in PDB provider. |
| `IDkmSymbolLocator.TryLoadSymbols` and its newer variants | Can participate in symbol loading, but operate on the module instance with its existing identity. They do not take an alternative `DkmPdbFileId`. Merely requesting another load does not repair an absent/unrecognized identity. |
| `DkmModule.Create` and `DkmModuleInstance.SetModule` | Let a symbol provider create and associate its own symbol module. `Create` does not load a native PDB or initialize the built-in PDB provider simply because a filename is supplied. `SetModule` associates a provider-owned module and raises the symbols-loaded event. |
| `DkmImageDebugDirectoryFormat` | Maps an `IMAGE_DEBUG_DIRECTORY.Type` integer to a symbol provider. Both NB10 and RSDS are type 2, so this is not a per-signature compatibility switch. |

There are two larger possible directions, neither established as an immediate fix:

1. **A DIA-backed custom symbol provider:** parse NB10, open and validate the
   original PDB through DIA, create a provider-owned `DkmModule`, and attach it
   with `SetModule`. Relevant interfaces include `IDkmSymbolQuery` (source
   positions and raw symbol-store interfaces), `IDkmSymbolDocumentCollectionQuery`
   and `IDkmSymbolDocumentSpanQuery` (breakpoint binding),
   `IDkmSymbolProviderCallback` (line/stepping information), and native symbol
   callbacks. Reusing the existing C++ evaluator and x86 PDB stack walker would
   also require their expected DIA interfaces and metadata to work. Showing a
   source name in a stack is not equivalent to complete native debugging.
2. **Replace or interpose on native module creation:**
   `DkmNativeModuleInstance.Create` accepts a symbol identity, but creates a new
   module instance and sends another load event; it is monitor-side API. It is
   not an identity setter for the Windows monitor's existing module. Handling
   suppression, address ownership, unload/reload events, and runtime integration
   would require further investigation. Do not treat cloning a module as a
   verified or low-risk substitute for a parser hook.

Concord supports method chaining and ordered components. That allows a plug-in
to handle a narrow case and defer others, but only at an API boundary actually
exposed by the dispatcher; it does not expose arbitrary private parser calls.
Reflection/private-field mutation would bypass this API model rather than
provide a supported compatibility fix.

**Assessment:** no small, documented "accept NB10 and feed this identity to the
existing PDB loader" hook was found in this debugger version. A custom provider
is a credible development project, not a proven immediate solution. For the
goal of debugging the untouched executable with the least custom machinery,
test WinDbg/CDB before building a Concord provider. The narrow next Concord
prototype, if pursued, should only log module-load identity and callback order;
it should establish the interception point before attempting symbol replacement.

## 10. Could another debugger backend solve it?

Potentially. Distinguish a debugger backend, its symbol reader, its DAP/MI
adapter, and the IDE frontend. A backend that accepts NB10 and reads PDB 2.00
could debug the original EXE without our patch, but source lines and typed locals
must be tested end-to-end for that particular version.

| Backend | Assessment for this project |
| --- | --- |
| WinDbg / CDB, using DbgEng and its symbol-handling stack | Initially unavailable; subsequently installed by the user. Agent verified x86 CDB `10.0.28000.2957` on the unpatched NB10 executable: private PDB symbols loaded, `Main.cpp:483` breakpoint hit, and typed locals displayed. The user then confirmed that WinDbg automatically finds source files on Step Into after configuring the source path. Integration into VS Code would need an appropriate adapter; it is not a `cppvsdbg` setting. |
| Native Windows Debugging (dbgeng) extension / `dap-dbgeng` | Installed by the user at version 0.3.0. The `Loader (Wine build, DbgEng)` configuration starts successfully, but tries to open the original `Z:\workspace\...\Main.cpp` path. Source inspection identified missing local source-path resolution in the adapter. A local adapter build and upstream contribution are the chosen next direction; the fix is not implemented yet. |
| VC6's own debugger, or an older Visual Studio native debug engine | Historically appropriate for this compiler and format. Not tested in this investigation. Running an old IDE/debugger on a current host is a separate concern. Modern Visual Studio can share Concord components, so simply installing the latest full IDE is not proof of different behavior. Do not assume a current IDE still offers an old "native compatibility mode". |
| GDB / MI through `cppdbg` | The installed GDB did not provide usable source debugging for the tested GNU-linked output; loading the current VC6-built output also did not expose usable source symbols. Not a verified replacement for these PDBs. GDB with a modern GCC/DWARF rebuild is a different, plausible toolchain. |
| LLDB / a suitable VS Code adapter | Not tested locally; `lldb` was not on PATH. PDB support depends on the build and reader. LLVM switched the Windows default toward its native reader, and DIA-reader availability is version-dependent. A DIA-capable reader is interesting because DIA reads our PDB, but discovery, x86 process control, breakpoints, and expressions still require verification. CodeLLDB's name alone does not guarantee VC6 compatibility. |
| Wine's winedbg / its GDB-proxy route | Another candidate, not tested. It would debug the application under Wine rather than the host's native Windows runtime. Its symbol support, availability in the image, and interactive/adapter setup would need verification, as would any behavior difference caused by running under Wine. |
| A custom DIA-backed debugger/adapter | Technically possible, but DIA only supplies symbol information. Process control, stepping, breakpoints, stack walking, expressions, and DAP integration still need implementation. Much more work than the reference patch. |

None of these untested alternatives should be recorded as a confirmed solution.

### Installing WinDbg/CDB

Install the current WinDbg using Microsoft's documented package:

```powershell
winget install --id Microsoft.WinDbg -e
```

The [official WinDbg installation page](https://learn.microsoft.com/windows-hardware/drivers/debugger/)
also provides direct-install and Microsoft Store routes. Modern WinDbg uses
the DbgEng family of debugging engines, distinct from Concord.

For **CDB**, run the [Windows SDK installer](https://developer.microsoft.com/windows/downloads/windows-sdk/)
and select **Debugging Tools for Windows**. Microsoft documents installing only
that component, without the other SDK features or Visual Studio. Typical paths:

```text
C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\cdb.exe
C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\cdb.exe
```

For this x86 executable, start with x86 CDB. Produce a fresh original NB10 image
with `./build-wine.ps1 -Rebuild`, rather than the debug wrapper that patches it.
Enable source-line support (`-lines`), set the symbol path to the Debug output
directory and the source path to Loader, then check symbol loading, an actual
source breakpoint, and typed locals. Merely attaching successfully or resolving
an exported/public name does not complete this test. Run
`./build-loader-debug.ps1` afterward to restore the currently supported F5 output.

### Confirmed CDB launch and source-path follow-up

After the Windows SDK debugger component was installed, these CDB binaries were
found under `C:\Program Files (x86)\Windows Kits\10\Debuggers`: `x86`, `x64`,
and `arm64`. The x86 version was tested against `Debug/Peter.exe`, whose
CodeView record was independently checked as `NB10` with a 64-byte allocation.
The executable was not rewritten for the CDB test.

Launch from the repository root:

```powershell
& "${env:ProgramFiles(x86)}\Windows Kits\10\Debuggers\x86\cdb.exe" -lines `
    -y "$PWD\Peter250src\Loader\Debug" `
    -srcpath "$PWD\Peter250src\Loader" `
    "$PWD\Peter250src\Loader\Debug\Peter.exe"
```

Commands used for the successful breakpoint/locals check:

```text
.reload /f Peter.exe
lmv m Peter
bp `Main.cpp:483`
g
.frame 0
dv /t
```

Observed: `C (private pdb symbols)` for Peter; `Breakpoint 0 hit`; the frame
resolved to `Peter!WinMainCRTStartup+0xc` at the Wine source path and line 483;
locals included `CFileMap`, `_SYSTEMTIME`, and integer variables.

The user's initial WinDbg session required manually opening source files. After
configuring the source path, the user confirmed that **Step Into automatically
finds and opens the correct local source files**. The PDB's `Z:\workspace` paths
do not exist on the Windows host. Configure a local source
search path separately from the symbol path. For a local session, the standard
command is `.srcpath C:\Users\<user>\repos\Peter\Peter250src\Loader`; append
additional source directories with `.srcpath+`. WinDbg also has `.lsrcpath` for
the client's local source path, relevant when debugging through a debugger
server. `.srcnoisy 1` enables source-loading diagnostics.

The confirmed modern WinDbg launch from the repository root is:

```powershell
WinDbgX.exe -lines `
    -y "$PWD\Peter250src\Loader\Debug" `
    -srcpath "$PWD\Peter250src\Loader" `
    "$PWD\Peter250src\Loader\Debug\Peter.exe"
```

Evidence provenance: the CDB checks were agent-run and established line-based
breakpoints and typed locals; the successful automatic source-file loading on
Step Into was confirmed by the user in WinDbg. The earlier unsuccessful `ls`/`lsa`
batch experiments in CDB do not negate the subsequently confirmed WinDbg UI behavior.

### VS Code DbgEng adapter: source-path bug and supported executable override

The installed extension is `svnscha.vscode-dap-dbgeng`, version 0.3.0, from
[svnscha/dap-dbgeng](https://github.com/svnscha/dap-dbgeng). It bundles a native
`dap-dbgeng.exe` DAP adapter that uses the installed SDK's DbgEng APIs.

The workspace now has two launch options:

* **Loader (Wine build, Windows debug)**: `cppvsdbg`, using the PDB-reference patch.
* **Loader (Wine build, DbgEng)**: `dbgeng`, using `Build Loader (Wine, VC6 symbols)`.
  This task calls `build-wine.ps1 -Rebuild` directly. The clean rebuild ensures
  the original NB10 output is restored when switching from the patched option.

The DbgEng launch specifies `sources` and `symbolPath`. These attributes are
supported, but **`sources` does not rewrite the paths in the adapter's DAP
responses** in version 0.3.0. There is no documented `sourceFileMap` option for
this adapter; copying the `cppvsdbg` setting into its launch configuration would
not implement the missing behavior.

Source inspection at the `v0.3.0` tag found:

* `src/service/dap_server_launch.cpp` reads `sources` and `symbolPath`.
* `src/debugger/debugger_session_symbols.cpp::set_source_path` sets `.srcpath`.
* `src/debugger/debugger_session_inspection.cpp::try_get_frame_source` calls
  `GetLineByOffset` and returns its original PDB path unchanged.
* `src/util/debugger_session_dap_factory.cpp::create_source` copies that path to
  DAP `Source.path`; VS Code then attempts to open the nonexistent Wine path.
* `src/service/dap_server_source.cpp` also attempts to read the supplied path
  directly, so its source-content handler does not compensate for that path.

This is separate from the NB10 discovery issue in Microsoft's debugger. DbgEng
can read the symbols; this adapter must resolve a source path for the IDE.

The installed extension already provides a supported custom-executable setting.
After building the patched adapter, a workspace `.vscode/settings.json` could use:

```json
{
    "dap-dbgeng.adapterPath": "${workspaceFolder}/.vscode/debuggers/dap-dbgeng.exe"
}
```

This is an example deployment location, not a file currently supplied by this
repository. Place the executable and any necessary runtime dependencies there
before enabling the override. The installed extension's `out/adapter.js`
(`resolveAdapterPath`) explicitly expands `${workspaceFolder}` in this setting
and selects an existing configured executable before its bundled one. A missing
configured file currently falls back to the bundled adapter with an Output
message, so verify the **dap-dbgeng** Output channel's `Starting adapter:` path.

The extension remains installed normally and still launches the adapter as a
separate process. The existing `dbgeng` launch configuration continues to work,
and the adapter loads the installed SDK `dbgeng.dll`. The TypeScript extension
does not need to be rebuilt or repackaged into a VSIX for this test. Start a new
debug session after changing the setting. Remove the setting to return to the
bundled adapter; ordinary extension updates can continue.

### Planned local fix and upstream contribution

The user intends to pursue this route and contribute the source-resolution fix
to **svnscha/dap-dbgeng**, not to Microsoft's `vscode-cpptools`. No adapter patch,
local binary build, executable override, upstream issue, or PR has been created
as part of this plan yet.

Proposed next steps for the implementing agent:

1. Read the adapter repository's contribution/build instructions and applicable
   repository instructions. Use a separate source checkout; build against the
   installed engine. Its documented build uses MSVC, CMake/Ninja, and vcpkg;
   this is adapter-development tooling, not a change to Loader's toolchain.
2. Fix source resolution centrally before emitting DAP sources. After obtaining
   the compile-time path from `GetLineByOffset`, call
   `IDebugSymbols::FindSourceFile` using the configured source search path and
   request a full canonical path (`DEBUG_FIND_SOURCE_FULL_PATH`). Use the resolved
   local path on success and retain the original path if no source is found.
   Handle the API's buffer sizing and failure results correctly. Avoid hardcoding
   `Z:\workspace`, a Windows username, or this project's directory structure.
3. Check all callers that emit source paths, including stack frames, disassembly,
   and source-content requests, so navigation and displayed content agree.
4. Add focused regression coverage: an existing direct path, a missing Wine-style
   absolute path resolved through `sources`, and a genuinely missing file that
   falls back without losing the frame/line. Include search-path ordering and
   duplicate basenames where relevant; use DbgEng's documented search behavior
   rather than an ad hoc basename-only replacement.
5. Build and select the local executable through `dap-dbgeng.adapterPath`. Keep
   Loader's original NB10/PDB 2.00 output. Verify the actual DAP `stackTrace`
   response names an existing local `Main.cpp`, a local source breakpoint binds
   and is hit, typed locals remain usable, and Step Into opens local source in
   VS Code. The earlier WinDbg UI success is not proof that this adapter fix works.
6. Follow upstream contribution conventions, run its required checks, and submit
   the narrowly scoped source-resolution fix with a reproducible test case when
   requested. Keep this project on the local build until a released adapter
   includes the fix, then remove the workspace override.

`FindSourceFile` searches directories and path suffixes in the source path and
can return the canonical local path; it does not require changing the EXE/PDB.
That is the intended reuse of the engine's existing source lookup, rather than
introducing another symbol conversion or modifying installed extension files.

## 11. Other implementation options

1. **Keep the current reference-only patch.** Verified, preserves VC6 linking
   behavior, and has no additional local compiler/linker dependency.
2. **Modern Microsoft relinking.** Consumes `/Z7` objects and emits normal modern
   PDB/RSDS output. Requires local tooling and a review of differing defaults.
3. **Ask Microsoft to support NB10 discovery in the native debugger.** Cleanest
   upstream outcome: the original EXE/PDB pair works without modifying artifacts.
4. **A launch-time wrapper or extension-side preprocessing.** Can apply the
   same patch to a debug copy, keeping an original deliverable untouched. Does
   not add native NB10 support. Renaming the EXE requires care because our helper
   derives the PDB filename from the executable basename.
5. **Investigate a Concord plug-in.** Potential backend extension route, with
   feasibility of the necessary hooks still unresolved.
6. **Port compilation to modern MSVC/Clang, or GCC with DWARF.** Produces debug
   formats intended for modern tools, but changing compiler/ABI/runtime behavior
   is a broader project than making the VC6 build debuggable.
7. **Extend an open-source reader/linker/backend.** LLD's old CodeView support or
   GNU's failing PDB path could be investigated upstream, but neither is an
   already-working replacement from the installed tools.

## 12. Questions a domain expert should ask

### Are we changing identity just to bypass symbol matching?

No. The replacement uses the identity actually exposed by DIA for this PDB:
timestamp in GUID Data1, twelve zero bytes, and the original age. A random GUID
or a freshly generated timestamp would not describe the matching database.
The helper assumes a correctly matched VC6 EXE/PDB from the build; it does not
open and independently validate the PDB before patching.

### Does RSDS imply a converted PDB, modern compiler, x64, or different code?

No. It is a reference-record layout. The final byte test confirmed that this
PDB stayed unchanged and the code stayed unchanged. This does not upgrade
language support, compiler code generation, ABI, runtime libraries, or mitigations.

### Could the original failure just be missing paths, stale files, or optimization?

Those are separate common failures, but do not explain the controlled A/B
experiment: same PDB, same code, corrected NB10 path still failing, RSDS succeeding.
For new reports, still check identity/age, symbol search paths, source mappings,
and whether the final EXE is the one actually being launched. `/Od` preserves
debuggability but does not cause recognition of a PDB-reference format.

### Is /Z7 strictly necessary for the reference patch?

No. The byte transformation itself does not depend on a compiler switch, and
the follow-up matrix verified full typed locals for `/Zi /PDBTYPE:CON` after the
reference patch, including without the compiler PDB. `/Z7` remains the configured
application build, but it is not the only usable input. `/Zi /PDBTYPE:SEPT` is a
different case: line breakpoints and integer locals worked after patching, while
struct/pointer types remained unreadable in the tested modern readers.

### Why can dumpbin say "Symbols stripped" when a valid PDB exists?

The PE/COFF header's legacy COFF-symbol-table and line-number flags are separate
from the CodeView debug directory and an external PDB. Those flags do not imply
that the external PDB lacks source symbols. Inspect the debug-directory record,
its identity, the matching PDB, and the debugger's actual load status rather than
inferring everything from the phrase "Symbols stripped".

### Is this a general PE/PDB repair tool?

No. It targets the known PE32 VC6 output. It requires the new record to fit in
the old allocation and assumes a same-basename PDB. It does not implement PE32+
support, embedded-symbol conversion, arbitrary database conversion, or exhaustive
validation of every malformed image. Its RSDS early return is an idempotence
shortcut, not validation that an already-RSDS image has correct symbols.

### What about checksums, signatures, and distribution?

The file bytes and therefore its hash change even though the code/layout do
not. The helper does not recompute a PE checksum or preserve Authenticode
signatures; the tested debug EXE was unsigned with a zero checksum. If signed
deliverables become relevant, apply the patch before signing or use a separate
debug copy. The current patch is for debugging, not an ABI or binary-identity guarantee.

### Does this work with symbol servers and every debugger?

We verified adjacent-file lookup and an explicit local symbol search path.
We have not verified symbol-server indexing/cache keys for this legacy-PDB,
RSDS-reference combination, other DIA versions, remote debugging, dump analysis,
or every debugger feature. Preserve both original and patched artifacts when
investigating those scenarios.

### What counts as sufficient verification?

At minimum: successful build; matching PDB loaded by the actual backend;
verified and hit source breakpoint; a source-resolved stack frame; typed locals
read successfully. A valid-looking header, a nonempty PDB, a public symbol name,
or a standalone DIA enumeration is not enough. Source line numbers and symbol
counts change as application code changes; `Main.cpp:483` is this snapshot's probe.

## 13. Reporting this to Microsoft

Public tracker: **[microsoft/vscode-cpptools](https://github.com/microsoft/vscode-cpptools)**.
Use its **[Bug Report - Debugger template](https://github.com/microsoft/vscode-cpptools/issues/new?template=2_debugger.yml)**.
This is the appropriate public entry point for the bundled native debugger,
even though the backend source is not in that repository. MIEngine is the
GDB/LLDB route and is not the component reproducing this failure.

Suggested title:

> cppvsdbg ignores VC6 NB10 PDB references although the matching PDB is readable by DIA

Include:

* Environment and exact extension/backend versions from section 2, plus any newer reproduction.
* An original, unpatched EXE with NB10, its matching PDB, and source for a minimal example.
* The actual message and debugger module status, not just a hollow-breakpoint screenshot.
* `launch.json`, source mappings, and symbol paths.
* Proof that DIA can load the original EXE/PDB pair.
* The controlled RSDS change, preserving the original age and timestamp-derived
  GUID, and evidence that the same PDB then yields a hit breakpoint and typed locals.
* Engine logs with `"logging": { "engineLogging": true, "trace": true, "traceResponse": true }`.

Keep EXE/PDB basenames consistent when creating attachments, or use separate
`original` and `patched` directories each containing `Peter.exe` and `Peter.pdb`.
No issue has been opened by the agent. A repository issue search for `NB10`
returned no matches during this investigation; search again before filing.
Microsoft can decide whether this is a bug or a legacy-format support request.

## 14. Reproducing the investigation and locating evidence

To reproduce the unpatched state, run `./build-wine.ps1 -Rebuild` directly.
That deliberately skips the metadata helper. Restore the working state with
`./build-loader-debug.ps1` afterward. Calling only an incremental raw build may
leave an already-patched EXE in place if the linker does not run again.

Machine-local tools and artifacts are under:

```text
C:\Users\<user>\AppData\Local\Temp\opencode
```

Useful files there, if still present:

* `verify_loader_pdb.py`: DIA inspection. Uses `comtypes`; accepts an optional
  DIA DLL path. It used both installed VS DIA and the DLL bundled with cpptools.
  COM registration was unnecessary: the DLL's class factory was loaded directly.
* `probe-loader-vsdbg.py` and `vsdbg-sign.js`: direct DAP probe against the
  installed adapter. Uses the installed VS Code runtime/handshake module.
  Launches with `stopAtEntry: false`, sets the source breakpoint, inspects module
  status/stack/scopes/locals, and terminates the debuggee after verification.
* `Peter-vsdbg-transcript.json` / `Peter-vsdbg-engine.log`: final backend evidence.
* `loader-vsdbg-transcript.json` / `loader-vsdbg-engine.log`: the initial direct
  session that reproduced rejection of the unpatched executable.
* `Peter-nb10mapped-vsdbg-transcript.json`, `Peter-rsdsmapped-vsdbg-transcript.json`,
  and `Peter-rsdsraw-vsdbg-transcript.json`: format/location experiments.
* `verify-vc6-reference-patch.py`: rebuilds the original image, applies the helper,
  checks allowed byte differences and unchanged PDB, then checks idempotence.
* `test-loader-gnu.ps1`, `loader-zig-objects.rsp`, and `Loader-resource.o`:
  alternative-linker inputs. `windres` converted the `.res` to a COFF object for GNU.
* `vc6-debug-switch-matrix/`: later isolated `/Zi` versus `/Z7` investigation.
  Contains `src/probe.cpp`, build scripts/results, original and RSDS-reference
  variants, DIA reports, actual vsdbg transcripts/results, and CDB logs. The
  supplementary `zi-sept-hostpath` case made the compiler PDB's recorded path
  accessible on the host. These diagnostics are not the polished standalone repro;
  the sharing requirements and matrix are in `VC6-DEBUG-FORMAT-MATRIX.md` and
  `VSDBG-NB10-REPRO-PROMPT.md`.

These are temporary diagnostics, not checked-in project requirements. Paths,
extension versions, VS Code runtime directories, and probe line numbers are
hardcoded and must be reviewed before reuse. The metadata test rebuilds artifacts;
do not run it as though it were a read-only inspection.

Some experimental EXEs point at the workspace's `Peter.pdb`; a later rebuild
replaces that PDB and breaks their old identity match. Leftover EXEs are therefore
not necessarily self-contained, still-matched test fixtures. Preserve an EXE/PDB
pair together or recreate the experiment from a fresh build.

Example commands from the repository root:

```powershell
uv run --no-project python "C:\Users\<user>\AppData\Local\Temp\opencode\probe-loader-vsdbg.py"
uv run --no-project --with comtypes python "C:\Users\<user>\AppData\Local\Temp\opencode\verify_loader_pdb.py" ./Peter250src/Loader/Debug/Peter.exe
```

The direct probe uses `internalConsole` to avoid terminal-launch plumbing; the
project launch uses `integratedTerminal`. The symbol format, module status,
source mapping, breakpoint binding/hit, and typed locals were exercised in the
real adapter, but this was not UI automation of the F5 session itself.

## 15. References

* [Microsoft PE format: debug directory](https://learn.microsoft.com/windows/win32/debug/pe-format#debug-directory-image-only)
* [Microsoft /Z7, /Zi, /ZI compiler options](https://learn.microsoft.com/cpp/build/reference/z7-zi-zi-debug-information-format)
* [Microsoft /DEBUG linker option](https://learn.microsoft.com/cpp/build/reference/debug-generate-debug-info)
* [DIA SDK overview](https://learn.microsoft.com/visualstudio/debugger/debug-interface-access/debug-interface-access-sdk)
* [LLVM PDB format: MSF, streams, and CodeView](https://llvm.org/docs/PDB/index.html)
* [Microsoft native debugger and its proprietary implementation](https://github.com/microsoft/vscode-cpptools/wiki/Microsoft-Native-Debugger-licensing-and-Microsoft-Visual-Studio-Code)
* [MIEngine: the cppdbg/GDB/LLDB adapter route](https://github.com/microsoft/MIEngine)
* [Concord samples and architecture](https://github.com/microsoft/ConcordExtensibilitySamples)
* [Concord plug-ins in VS Code cppvsdbg](https://github.com/microsoft/ConcordExtensibilitySamples/wiki/Support-for-VS-Code-cppvsdbg-Scenarios)
* [Concord component discovery, filtering, and chaining](https://github.com/microsoft/ConcordExtensibilitySamples/wiki/Component-discovery-and-configuration)
* [DkmModuleInstance.SymbolFileId (read-only)](https://learn.microsoft.com/dotnet/api/microsoft.visualstudio.debugger.dkmmoduleinstance.symbolfileid)
* [DkmPdbFileId.Create](https://learn.microsoft.com/dotnet/api/microsoft.visualstudio.debugger.symbols.dkmpdbfileid.create)
* [Module-load notification API](https://learn.microsoft.com/dotnet/api/microsoft.visualstudio.debugger.componentinterfaces.idkmmoduleinstanceloadnotification)
* [DkmModuleInstance.SetModule](https://learn.microsoft.com/dotnet/api/microsoft.visualstudio.debugger.dkmmoduleinstance.setmodule)
* [DkmImageDebugDirectoryFormat](https://learn.microsoft.com/dotnet/api/microsoft.visualstudio.debugger.symbols.dkmimagedebugdirectoryformat)
* [Custom symbol-provider discussion](https://github.com/microsoft/ConcordExtensibilitySamples/issues/59)
* [Install WinDbg](https://learn.microsoft.com/windows-hardware/drivers/debugger/)
* [Install Debugging Tools for Windows, including CDB](https://learn.microsoft.com/windows-hardware/drivers/debugger/debugger-download-tools)
* [WinDbg/CDB source paths](https://learn.microsoft.com/windows-hardware/drivers/debugger/source-path)
* [.srcpath and .lsrcpath](https://learn.microsoft.com/windows-hardware/drivers/debuggercmds/-srcpath---lsrcpath--set-source-path-)
* [DbgHelp symbol-file capabilities](https://learn.microsoft.com/windows/win32/debug/symbol-files)
* [LLDB's change to the native PDB reader](https://github.com/llvm/llvm-project/pull/165363)
* [Native Windows Debugging (dbgeng) extension](https://marketplace.visualstudio.com/items?itemName=svnscha.vscode-dap-dbgeng)
* [dap-dbgeng source and contribution entry point](https://github.com/svnscha/dap-dbgeng)
* [Adapter source lookup at v0.3.0](https://github.com/svnscha/dap-dbgeng/blob/v0.3.0/src/debugger/debugger_session_inspection.cpp)
* [IDebugSymbols::FindSourceFile](https://learn.microsoft.com/windows-hardware/drivers/ddi/dbgeng/nf-dbgeng-idebugsymbols-findsourcefile)
* [Archived Microsoft KB318135: VC6 separate-type-pool incompatibility](https://ftp.zx.net.nz/pub/archive/ftp.microsoft.com/MISC/KB/en-us/318/135.HTM)
