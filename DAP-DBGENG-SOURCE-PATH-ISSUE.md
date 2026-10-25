# Configured `sources` paths are not used to resolve build-machine source paths in stack frames

## Summary

The debugger successfully loads my executable's symbols, but VS Code tries to
open the original build-machine source path from the PDB instead of finding the
corresponding local file using the configured `sources` directories.

For example, the PDB references:

```text
Z:\workspace\Peter250src\Loader\Main.cpp
```

That path exists in the Wine build environment, but not on the Windows host.
The local file is available under:

```text
${workspaceFolder}/Peter250src/Loader/Main.cpp
```

Adding the local directory to `sources` does not resolve the problem.

## Environment

* Extension: `svnscha.vscode-dap-dbgeng` **0.3.0**
* VS Code: **1.143.1**, x64
* Windows build: **10.0.26200**
* Windows SDK Debugging Tools installed
* Target: x86 Windows executable compiled with MSVC6 using `/Z7` and linked with `/DEBUG`
* Symbols: matching PDB 2.00 file, referenced by the executable's original NB10 record

## Configuration

```json
{
    "name": "Loader (DbgEng)",
    "type": "dbgeng",
    "request": "launch",
    "program": "${workspaceFolder}/Peter250src/Loader/Debug/Peter.exe",
    "cwd": "${workspaceFolder}/Peter250src/Loader/Debug",
    "stopAtEntry": true,
    "sources": [
        "${workspaceFolder}/Peter250src/Loader"
    ],
    "symbolPath": [
        "${workspaceFolder}/Peter250src/Loader/Debug"
    ]
}
```

## Steps to reproduce

1. Build an executable and PDB in an environment whose absolute source paths do
   not exist on the debugging machine.
2. Make the corresponding source files available locally.
3. Configure `sources` to include the local source directory.
4. Launch the debugger and stop in a function with source information.
5. Select its stack frame or step through the code.

## Actual behavior

VS Code attempts to open the original PDB path:

```text
Z:\workspace\Peter250src\Loader\Main.cpp
```

The file cannot be opened, despite the corresponding local file being present in
a configured source directory.

## Expected behavior

The adapter should resolve the recorded source filename through DbgEng's
configured source search path and return the existing local filename in DAP
`Source.path`.

If no local file can be found, retaining the original path as a fallback would
be reasonable.

## Comparison with WinDbg

The same executable and PDB work in standalone WinDbg. With its source path
configured to the local Loader directory, stepping into code automatically
finds and opens the correct local files.

This appears to be separate from symbol loading: the symbols are readable and
source-line information is available.

## Source investigation

In version 0.3.0:

* `set_source_path` in `src/debugger/debugger_session_symbols.cpp` sets `.srcpath`.
* `try_get_frame_source` in `src/debugger/debugger_session_inspection.cpp` calls
  `GetLineByOffset` and returns the original filename unchanged.
* `create_source` in `src/util/debugger_session_dap_factory.cpp` copies that
  filename directly into DAP `Source.path`.
* The source-request handler also tries to open the supplied path directly.

## Suggested approach

After obtaining the filename from `GetLineByOffset`, resolve it using
[`IDebugSymbols::FindSourceFile`](https://learn.microsoft.com/windows-hardware/drivers/ddi/dbgeng/nf-dbgeng-idebugsymbols-findsourcefile),
or its wide-character equivalent, requesting a full canonical path.

This would reuse DbgEng's existing source-path search behavior rather than
requiring changes to the executable or PDB.

Useful regression cases would include:

* An existing original source path.
* A missing build-machine path resolved through `sources`.
* A genuinely unavailable source file that falls back gracefully.

I'm interested in contributing a fix and tests if this approach fits the project.
