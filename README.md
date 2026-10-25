# Peter

Original README is [here](./readme-old.txt). See original project here: https://github.com/Panda381/Peter

I'm working on getting this thing to compile on modern compilers. May go for functionality improvements (or removals!) later.

## Debugging Loader in VS Code

On Windows, install VS Code with the Microsoft C/C++ extension, PowerShell 7,
and Podman. Start the Podman machine with `podman machine start`.
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

`/Od` keeps optimization disabled. The VS Code launch configuration maps Wine's
`Z:\workspace` source paths back to this checkout and searches the Debug directory
for symbols.

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
