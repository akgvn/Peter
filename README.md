# Peter

Original README is [here](./readme-old.txt). See original project here: https://github.com/Panda381/Peter

I'm working on getting this thing to compile on modern compilers. May go for functionality improvements (or removals!) later.

## Debugging Loader in VS Code

On Windows, install VS Code with the Microsoft C/C++ extension, PowerShell 7,
uv (to run the Python helper), and Podman. Start the Podman machine with
`podman machine start`.
The Wine image supplies the VC6 compiler, linker, and libraries; the C/C++
extension supplies the Windows debugger.

Select **Loader (Wine build, Windows debug)** in Run and Debug, then press **F5**.
The pre-launch task runs `build-loader-debug.ps1`, which calls `build-wine.ps1`
to compile and link with VC6 under Wine, producing
`Peter250src/Loader/Debug/Peter.exe` and its matching `Peter.pdb`.
You can also run `./build-loader-debug.ps1` from PowerShell.

Loader's Debug configuration uses `/Z7` to embed full debug information in the
object files. The VC6 linker collects those symbols into the final PDB.
`build-loader-debug.ps1` then updates the executable's CodeView PDB reference
from `NB10` to `RSDS`, using the PDB's timestamp-derived GUID and age. This lets
VS Code's debugger discover the VC6 PDB. The PDB contents, executable code,
section layout, and file size are preserved. The PDB is referenced by filename
so it can be found beside the executable.

The reference patch is implemented in
[`scripts/set-vc6-pdb-reference.py`](scripts/set-vc6-pdb-reference.py), using only
Python's standard library. The build wrapper invokes it through uv. To apply it
to an existing VC6 build directly:

```powershell
uv run --no-project python scripts/set-vc6-pdb-reference.py Peter250src/Loader/Debug/Peter.exe
```

An already-RSDS executable is left unchanged. Run the helper's preservation and
validation tests with:

```powershell
uv run --no-project python -m unittest discover -s scripts -p test_set_vc6_pdb_reference.py
```

`/Od` keeps optimization disabled. The VS Code launch configuration maps Wine's
`Z:\workspace` source paths back to this checkout and searches the Debug directory
for symbols.

For the investigation history, format details, debugger architecture, alternative
backends, and fresh-agent context, see [the debugging handoff](DEBUGGING-HANDOFF.md).
The [VC6 debug-format matrix](VC6-DEBUG-FORMAT-MATRIX.md) records the measured
behavior and explains [compiler `/Zi` versus `/Z7`](VC6-DEBUG-FORMAT-MATRIX.md#what-zi-and-z7-mean)
as well as
[consolidated versus separate-type PDBs](VC6-DEBUG-FORMAT-MATRIX.md#what-con-and-sept-mean).
VC6's `/PDBTYPE:CON` consolidates compiler type information into the final linker
PDB; `/PDBTYPE:SEPT` keeps separate compiler type pools. This is independent of
the EXE's NB10/RSDS PDB-reference format.

### Experimental LIEF rebuild converter

[`scripts/rebuild-pdb-reference.py`](scripts/rebuild-pdb-reference.py) provides a
separate-output NB10 → RSDS converter. LIEF rebuilds the debug data so a larger
PDB reference can fit without relying on space in the original record. Run the
converter with **Loader (Wine build, LIEF rebuild)** in VS Code:

1. Ensure the Podman machine is running (`podman machine start` if needed).
2. Set a breakpoint on `VerzeOS = (int)::GetVersion();` in
   `Peter250src/Loader/Main.cpp` (currently line 483).
3. Select **Loader (Wine build, LIEF rebuild)** in Run and Debug and press **F5**.
   The tasks clean-build the original NB10 EXE/PDB, then use uv to run the LIEF
   converter and create `Debug/Peter-lief.exe`.
4. The debugger stops at entry. Continue with **F5** to reach the source
   breakpoint, then use **F10** to step. Check that the call stack shows
   `WinMainCRTStartup()` and Locals displays types such as `CFileMap` and
   `_SYSTEMTIME`. Values for locals not yet initialized are not meaningful.

The session launches `Peter-lief.exe` and loads its symbols from `Peter.pdb`.
The task forces a clean build so an earlier in-place RSDS patch cannot turn the
rebuild test into an unchanged copy. To build and convert manually, run the
script directly through uv, which installs its declared `lief==1.0.0` dependency:

```powershell
# Produce original NB10 input and its matching PDB.
./build-wine.ps1 -Rebuild
uv run --no-project scripts/rebuild-pdb-reference.py `
    Peter250src/Loader/Debug/Peter.exe `
    -o Peter250src/Loader/Debug/Peter-lief.exe
```

The default reference preserves the **original PDB basename**, here `Peter.pdb`,
even when the output EXE is renamed. Keep that matching PDB beside the output,
or set an explicit filename/path with `--pdb-reference 'C:\symbols\Peter.pdb'`.
The converter writes a separate output and leaves the input and PDB intact.
Already-RSDS input is copied unchanged; reference overrides apply only to NB10.
For non-ASCII legacy names, supply `--nb10-encoding`, such as `cp1250`, or an
explicit reference. New references use UTF-8.

Rebuilding can add a section, grow the file, and move the overlay. The converter
checks code/section-RVA preservation and recomputes the PE checksum, but a
program that depends on physical file offsets still needs its own runtime test.
The overlay can retain the old NB10 path. Actual vsdbg checks passed for rebuilt
Loader and `/Zi CON` and `/Z7 CON` probes; PE32+ coverage is structural only.
See the [rebuild details and limits](DEBUGGING-HANDOFF.md#experimental-lief-rebuild-companion).

Run both helpers' regression tests with:

```powershell
uv run --no-project --with lief==1.0.0 python -m unittest discover -s scripts -p 'test_*pdb_reference.py' -v
```

### DbgEng extension and a local adapter build

The **Loader (Wine build, DbgEng)** launch option uses the
[Native Windows Debugging (dbgeng) extension](https://marketplace.visualstudio.com/items?itemName=svnscha.vscode-dap-dbgeng)
and a clean Wine build with the original VC6 symbols. Its installed version 0.3.0
starts the debugger, but returns the PDB's `Z:\workspace` source paths to VS Code
instead of resolving them through the configured source directories.

The planned fix is in the open-source
[`dap-dbgeng` adapter](https://github.com/svnscha/dap-dbgeng): use DbgEng's
`FindSourceFile` API to resolve the local source path before returning it to
VS Code, then contribute the fix upstream.

The installed extension supports selecting a custom adapter executable. Once a
patched adapter has been built and placed at the path below, add this to
`.vscode/settings.json`:

```json
{
    "dap-dbgeng.adapterPath": "${workspaceFolder}/.vscode/debuggers/dap-dbgeng.exe"
}
```

Keep any required runtime dependencies beside that executable. The existing
`"type": "dbgeng"` launch configuration and installed SDK `dbgeng.dll` continue
to be used; repackaging the extension is unnecessary. Confirm the selected
executable in the **dap-dbgeng** Output channel when starting a new session.
Removing the setting restores the bundled adapter. Building the adapter follows
its upstream MSVC/CMake/Ninja/vcpkg instructions; Loader itself still builds with
VC6 under Wine.

The local build and its source-resolution fix are planned, not yet implemented
or verified. See the [handoff's contribution plan](DEBUGGING-HANDOFF.md#planned-local-fix-and-upstream-contribution)
for the source locations and acceptance checks.

## Debugging Loader in WinDbg

WinDbg can debug the original VC6 executable and PDB directly, including source
breakpoints and typed locals. Build with the Wine script to produce the original
`NB10` PDB reference:

```powershell
./build-wine.ps1 -Rebuild
```

Install modern WinDbg with `winget install --id Microsoft.WinDbg -e`, then launch
it from the repository root with symbol and source search paths configured:

```powershell
WinDbgX.exe -lines `
    -y "$PWD\Peter250src\Loader\Debug" `
    -srcpath "$PWD\Peter250src\Loader" `
    "$PWD\Peter250src\Loader\Debug\Peter.exe"
```

`-y` locates the PDB; `-srcpath` locates the local source files despite the
`Z:\workspace` build paths stored in the PDB. With that source path configured,
**Step Into automatically finds and opens the source files**; opening each file
manually is unnecessary. This behavior has been confirmed in WinDbg.

For an already-open session, set the source directory in WinDbg's command window
(replace `<user>` with your Windows account name):

```text
.srcpath C:\Users\<user>\repos\Peter\Peter250src\Loader
```

Append additional source directories with `.srcpath+`. For source-loading
diagnostics, use `.srcnoisy 1`.

The Windows SDK's **Debugging Tools for Windows** component also supplies classic
WinDbg and CDB. The x86 executables are normally under
`C:\Program Files (x86)\Windows Kits\10\Debuggers\x86`.

## VC6 vs modern MSVC linker defaults (Loader)

For reference, linking VC6-compiled objects with a modern Windows linker gives
different PE headers and image layouts because the linker defaults have changed.
The debug workflow above uses the VC6 linker in the Wine image.

The following comparison was checked with `dumpbin /headers` on
`Peter250src/Loader/Debug/Peter.exe` (linker 6.00) and `Peter-vscode.exe`
(linker 14.51, Visual Studio 2026), before the PDB-reference adjustment above.
These are the observed settings for our x86 GUI Debug builds; defaults can depend
on the target and toolset version.

| Setting | VC6 output | Modern output | Effect / controlling option |
| --- | --- | --- | --- |
| ASLR | No dynamic-base flag | Dynamic-base flag set | Modern [`/DYNAMICBASE`](https://learn.microsoft.com/en-us/cpp/build/reference/dynamicbase-use-address-space-layout-randomization) defaults to enabled. The image can load at a randomized address; `0x00400000` is still its preferred base, not a guaranteed runtime address. `/DYNAMICBASE:NO` disables this flag. |
| Base relocations | Relocations stripped; no `.reloc` section | Relocations retained in `.reloc` | The modern ASLR-enabled output can be rebased. [`/FIXED`](https://learn.microsoft.com/en-us/cpp/build/reference/fixed-fixed-base-address) removes relocation data and requires the preferred base; `/FIXED:NO` retains it. Disabling ASLR and stripping relocations are separate choices. |
| DEP compatibility | No NX-compatible flag | NX-compatible flag set | Modern [`/NXCOMPAT`](https://learn.microsoft.com/en-us/cpp/build/reference/nxcompat-compatible-with-data-execution-prevention) defaults to enabled. This opts the executable into DEP; data pages are not executable merely because they contain machine code. `/NXCOMPAT:NO` clears the flag, but effective DEP also depends on Windows policy. |
| Terminal Server awareness | Flag absent | Flag set | Modern [`/TSAWARE`](https://learn.microsoft.com/en-us/cpp/build/reference/tsaware-create-terminal-server-aware-application) defaults to enabled for GUI and console EXEs. This disables legacy Terminal Server compatibility handling for things such as Windows-directory INI files and registry access. `/TSAWARE:NO` clears the flag. |
| File alignment | `0x1000` (4096 bytes) | `0x200` (512 bytes) | Section offsets and padding on disk differ. [`/FILEALIGN:4096`](https://learn.microsoft.com/en-us/cpp/build/reference/filealign) can explicitly select the observed VC6 alignment. The linker chooses an alignment when this option is omitted; 512 is the observed modern value here, not a universal default. |
| Minimum subsystem version | `4.00` | `6.00` | Both commands specify `/SUBSYSTEM:WINDOWS` without a version. Modern [`/SUBSYSTEM`](https://learn.microsoft.com/en-us/cpp/build/reference/subsystem-specify-subsystem) defaults to `6.00` for x86 Windows applications. An explicit version, such as `/SUBSYSTEM:WINDOWS,5.01`, changes the declared minimum, subject to toolset support; it does not establish compatibility of the code and imported APIs. The OS-version header field also changed from `4.00` to `6.00` in these outputs. |
| Debug-symbol format | PDB 2.00, referenced by an `NB10` record | Modern PDB, referenced by an `RSDS` GUID/age record | Modern [`/DEBUG`](https://learn.microsoft.com/en-us/cpp/build/reference/debug-generate-debug-info) means `/DEBUG:FULL` and collects the `/Z7` object symbols into the final PDB. The VC6 project's `/PDBTYPE:SEPT` is an explicit legacy project setting, not a modern default. |

### Options used in the comparison

* Both linker commands explicitly use `/DEBUG`, `/INCREMENTAL:NO`,
  `/MACHINE:I386`, `/SUBSYSTEM:WINDOWS`, and `/NODEFAULTLIB`.
* Modern `/DEBUG` normally implies incremental linking, but our
  `/INCREMENTAL:NO` overrides it.
* Modern [`/OPT`](https://learn.microsoft.com/en-us/cpp/build/reference/opt-optimizations)
  defaults to `/OPT:NOREF,NOICF` with `/DEBUG`: unreferenced COMDATs are kept and
  identical COMDATs are not folded. Without `/DEBUG`, the modern defaults are
  `/OPT:REF,ICF`. `/INCREMENTAL:NO` does not turn those optimizations on, and
  compiler `/Od` is independent of linker optimization settings.
* Both images still use a preferred base of `0x00400000`, a memory section
  alignment of 4096 bytes, and 1 MiB reserve / 4 KiB commit for the stack and
  heap. File alignment and memory section alignment are different settings.
* Relinking does not recompile the code or add compiler features such as `/GS`.
  `/NODEFAULTLIB` still excludes implicit runtime libraries, and both outputs
  select Loader's custom `WinMainCRTStartup` function as the entry point.

### Layout and diagnostics

Function addresses, section sizes, raw file offsets, and the entry-point RVA can
change between the two linkers. Use each image's PE headers and matching PDB
when interpreting addresses or locating embedded data; changing `/FILEALIGN`
alone does not reproduce the VC6 layout.

The modern linker also reports `LNK4254` for the existing
`/MERGE:.CRT=.data` directive in `Loader/Main.cpp`: `.CRT` is read-only while
`.data` is writable. The resulting merged section is writable. This is a
diagnostic about the existing section merge, separate from debug-symbol format.

To inspect the current outputs from a Visual Studio developer shell:

```powershell
dumpbin /headers Peter250src/Loader/Debug/Peter.exe
dumpbin /headers Peter250src/Loader/Debug/Peter-vscode.exe
```
