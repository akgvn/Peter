# VC6 /Zi versus /Z7: measured debugger behavior

Recorded 2026-10-25. These tests used an isolated 21-line C++ program, not Loader.
They refine the [standalone repro prompt](VSDBG-NB10-REPRO-PROMPT.md).

## Summary

There are two independent compatibility issues:

1. **Executable-side symbol discovery:** the tested `vsdbg` rejects the original
   NB10 reference for both `/Zi` and `/Z7`. An equivalent RSDS reference fixes
   discovery for both; changing compiler storage does not select RSDS.
2. **Separate type pools:** `/Zi /PDBTYPE:SEPT` leaves the user-defined struct and
   pointer types unreadable in these modern readers. The RSDS-reference adjustment
   fixes discovery but not that separate type-information issue.

**Use both `/Z7 /PDBTYPE:CON` and `/Zi /PDBTYPE:CON` for the primary Microsoft
repro.** They isolate the NB10 discovery problem without the separate-type-pool
failure. Keep `/PDBTYPE:SEPT` as a clearly labeled secondary diagnostic case.

## What /Zi and /Z7 mean

`/Zi` and `/Z7` are **compiler options**, passed to `cl.exe`. Both request full
symbolic debugging information, including function/variable names, types, and
source-line information. They primarily differ in where the compiler puts that
information and what extra artifacts later tools need. `/Z7` is not a reduced
"line numbers only" mode, and `/Zi` is not automatically better debugging data.

| Aspect | `/Z7` | `/Zi` |
| --- | --- | --- |
| Compiler output | Embeds symbolic debug information in the OBJ. | Uses a separate compiler PDB, with references to it in the OBJ. |
| Compiler PDB | No compiler PDB is produced by this mode in the tested build. | VC6 normally uses `vc60.pdb`; `/Fdcompiler.pdb` selects an explicit compiler database name. |
| OBJ / static-library distribution | Debug data travels with the objects and libraries made from them. These files can be larger. | The matching compiler PDB must also be available when consuming their debug information, particularly at link time. |
| Linker input | The linker reads the embedded OBJ debug data directly. | The linker reads the compiler PDB as needed, then applies its consolidation/separate-types policy. |
| Final EXE's PDB | The linker can still generate a final PDB with `/DEBUG`. "No compiler PDB" does not mean "no final PDB". | A final linker PDB is also generated in our `/DEBUG` builds. With `CON`, it can be self-contained; with `SEPT`, separate compiler type pools remain relevant. |
| Optimization | Does not substitute for an explicit optimization choice. We use `/Od`. | Also does not substitute for `/Od`; requesting debug information does not itself mean unoptimized code. |
| VC6 minimal rebuild | `/Gm` is unavailable with `/Z7`. | `/Zi` can be used with the old minimal-rebuild mechanism; `/Gm` was deliberately omitted from this comparison. |

Conceptually:

```text
/Z7:
  source -> cl.exe -> OBJ containing code + debug information
  OBJ -> link.exe /DEBUG -> EXE + final linker PDB

/Zi:
  source -> cl.exe -> OBJ + compiler PDB
  those inputs -> link.exe /DEBUG -> EXE + final linker PDB
  /PDBTYPE:CON or /PDBTYPE:SEPT determines the final type-storage arrangement
```

The following are separate choices and should be recorded independently:

1. **Compiler storage:** `/Zi` or `/Z7`.
2. **VC6 linker type consolidation:** `/PDBTYPE:CON` or `/PDBTYPE:SEPT`.
3. **Debug-data/container versions:** determined by the producing toolchain.
4. **EXE-to-PDB reference:** NB10 from the original VC6 linker, or our equivalent
   RSDS metadata adjustment for `vsdbg` discovery.
5. **Source-file lookup:** the debugger's source search paths / mapping behavior.

Neither compiler switch inherently selects NB10 versus RSDS or PDB 2.00 versus
PDB 7.0. The same option name on a modern compiler need not produce the same
CodeView encoding as VC6; this matters when evaluating another linker's support.
The "C7 Compatible" name for `/Z7` does not mean "PDB version 7".

Also distinguish **`/Zi` from `/ZI`**: uppercase `/ZI` requests Edit and Continue
support and can have additional requirements/side effects. It was not tested in
this matrix and must not be silently substituted for `/Zi`.

The tests here did not use precompiled headers. PCH-bearing objects/libraries
have additional debug-artifact considerations, so the simple `/Z7` diagram is
not a claim that an arbitrary library can discard all PCH-related objects.

See [Microsoft's compiler-option reference](https://learn.microsoft.com/cpp/build/reference/z7-zi-zi-debug-information-format)
for the switch definitions; the measured VC6 behavior is recorded below.

## What CON and SEPT mean

`/PDBTYPE` is a **VC6 linker option** controlling how type information from
compiler PDBs is incorporated into the final debug database. It is separate
from the compiler's `/Zi` or `/Z7` storage choice. VC6's linker help lists the
long spellings as `CON[SOLIDATE]` and `SEPT[YPES]`.

There can be two different PDB products in a `/Zi` build:

* **Compiler PDB:** written by `cl.exe`, traditionally `vc60.pdb`, or explicitly
  named with `/Fdcompiler.pdb`. It contains compiler-generated type information.
* **Linker PDB:** written by `link.exe`, such as `probe.pdb`, explicitly named
  with `/PDB:probe.pdb`. The EXE's NB10 reference identifies this final PDB.

Keep these filenames distinct. The compiler PDB and linker PDB have different
roles; the word "PDB" does not mean there is always only one database to retain.

| Aspect | `/PDBTYPE:CON` | `/PDBTYPE:SEPT` |
| --- | --- | --- |
| Meaning | Consolidate type information | Keep separate type pools |
| With `/Zi` inputs | The linker copies/consolidates the required type information from available compiler PDBs into its final PDB. | The linker leaves type information in the compiler PDBs rather than consolidating it into the final PDB. |
| Debug artifacts needed afterward | For the tested consolidated program, the EXE and final linker PDB sufficed; the compiler PDB was not needed for debugging. | Historically requires the corresponding compiler PDBs as well as the final linker PDB, and a debugger that understands the separate-type-pool format. |
| Historical motivation | A more self-contained symbol database, at the cost of doing consolidation during linking. | Avoid copying/consolidating all type information on each link, reducing that work in the original toolchain. It was the VC6 IDE's normal Win32 Debug setting. |
| Modern-reader behavior tested here | Full user-defined types and member inspection were available. | `/Zi SEPT` source lines and primitive locals were readable, but struct/pointer types were not, even with the compiler PDB available. |

Conceptually, for `/Zi`:

```text
CON:
  cl.exe -> probe.obj + compiler.pdb
  link.exe reads both -> probe.exe + probe.pdb containing consolidated types
  debug using probe.exe + probe.pdb

SEPT:
  cl.exe -> probe.obj + compiler.pdb
  link.exe -> probe.exe + probe.pdb, with types left in separate compiler pools
  debugging requires those additional databases AND support for that old layout
```

Consolidation still needs the relevant compiler PDBs **at link time**. `CON`
cannot reconstruct type information that was already unavailable to the linker.
It also does not embed the actual source-file text; local source lookup remains
a separate requirement.

### Interaction with /Z7 and other inputs

With `/Z7`, the application's type information is in its OBJ rather than in a
compiler PDB. The linker can collect those embedded types directly. In this tiny
test, both `CON` and `SEPT` therefore produced usable final application types
for the `/Z7` input. That does not prove `SEPT` is harmless for every `/Z7`
application: linked libraries or other OBJ inputs may themselves have been built
with `/Zi` and depend on separate compiler PDBs.

### What this option does not change

`CON` versus `SEPT` does not select NB10 versus RSDS, convert PDB 2.00 to PDB 7.0,
enable source-path mapping, or turn compiler optimization on/off. All four
original test outputs were PDB 2.00/NB10 and had identical executable `.text`
bytes. This option changes the organization/dependencies of debug information.

Our RSDS-reference script changes only how the EXE identifies its final PDB. It
does **not** merge separate type pools or make an unsupported type layout readable.
Primitive types such as `int` can still be understood while records describing
a user-defined struct or a pointer to it are unavailable. That explains why a
line breakpoint and an integer local can work even when richer inspection fails.

**Practical choice:** explicitly select `CON` for the portable `/Zi` and `/Z7`
reproduction cases, and retain `SEPT` only as a separately identified diagnostic.
Treat `/PDBTYPE` as a legacy-toolchain option; do not assume current Microsoft
linkers expose the same switch or inherit VC6's IDE defaults.

## Toolchain and fixture

* VC6 compiler `12.00.8804`, linker `6.00.8447`, under the existing Wine image.
* Microsoft C/C++ extension `1.34.4`; its bundled `vsdbg` and DIA DLL.
* x86 CDB `10.0.28000.2957` from the Windows SDK.
* Four independent clean output directories, with identical source and runtime,
  optimization, warning, and subsystem settings. `/Gm` and PCH were not enabled.

The program used a conventional static-CRT console entry point:

```cpp
struct Sample
{
    int x;
    int y;
};

int compute(Sample* item, int bias)
{
    int subtotal = item->x + item->y;
    int result = subtotal + bias;
    return result; // BREAK_HELPER
}

int main()
{
    Sample sample = {10, 20};
    Sample* pointer = &sample;
    int bias = 12;
    int result = compute(pointer, bias); // BREAK_MAIN
    return result == 42 ? 0 : 1; // BREAK_AFTER
}
```

Compiler command, changing only the selected debug switch:

```text
cl.exe /nologo /Z7 /Od /MT /W3 /c /Foprobe.obj /Fdcompiler.pdb Z:\workspace\src\probe.cpp
cl.exe /nologo /Zi /Od /MT /W3 /c /Foprobe.obj /Fdcompiler.pdb Z:\workspace\src\probe.cpp
```

Linker command, changing only the selected PDB type:

```text
link.exe /nologo /debug /incremental:no /pdbtype:con /machine:i386 /subsystem:console /out:probe.exe /pdb:probe.pdb probe.obj kernel32.lib user32.lib advapi32.lib
link.exe /nologo /debug /incremental:no /pdbtype:sept /machine:i386 /subsystem:console /out:probe.exe /pdb:probe.pdb probe.obj kernel32.lib user32.lib advapi32.lib
```

The compiler wrote `compiler.pdb` for `/Zi`, not for `/Z7`. Every original EXE
had an NB10 reference and a PDB 2.00 linker PDB. All four `.text` sections were
byte-identical. Their SHA-256 was:

```text
065671f2bb85db64b8cd1f63b0ce2e4456ba93c923e46250dca5f935ec95d482
```

For each build, original and RSDS-reference variants were copied from the same
EXE/PDB pair. Only the RSDS variant's EXE reference was adjusted with
`scripts/set-vc6-pdb-reference.ps1`; its PDB bytes were verified unchanged.

## Results

| Compiler | Linker | Actual vsdbg, original NB10 | Actual vsdbg, RSDS reference | CDB, original NB10 |
| --- | --- | --- | --- | --- |
| `/Z7` | `/PDBTYPE:CON` | Rejected as not built with debug information; breakpoint unbound | Symbols loaded; source breakpoint hit; `Sample`, `Sample *`, and integer locals available; fields `x=10`, `y=20` readable | Source breakpoint hit; struct/pointer/integer locals typed |
| `/Z7` | `/PDBTYPE:SEPT` | Same rejection | Same successful source/typed-local result as `/Z7 CON` | Same successful typed-local result |
| `/Zi` | `/PDBTYPE:CON` | Same rejection | Symbols loaded; breakpoint hit; full struct/pointer/integer types and member values available | Source breakpoint hit; full local types available |
| `/Zi` | `/PDBTYPE:SEPT` | Same rejection | Symbols loaded and breakpoint hit; integer locals readable, but `sample` and `pointer` fail evaluation and have no reported type | Breakpoint hit and integers readable; struct/pointer locals reported as `<CLR type>` / `<unknown base type 80000013>` |

DIA could open every linker PDB and enumerate the functions and source lines.
For `/Zi SEPT`, user-defined struct/pointer type access returned a null COM
pointer, while basic integer types remained available. Thus neither a successful
PDB open nor a hit source breakpoint proves that type inspection is complete.

### Compiler-PDB availability checks

* `/Zi CON` continued to provide full typed locals with only the EXE and final
  PDB copied into an isolated variant directory. `compiler.pdb` was absent there,
  its Wine build path did not exist on the host, and each reader/debugger ran in
  a fresh process. This confirms the tested consolidated pair was self-contained.
* `/Zi SEPT` was tested both with `compiler.pdb` beside the EXE and without it.
  Both arrangements still failed to expose the user-defined types.
* A supplementary `/Zi SEPT` build deliberately recorded an actual host-visible
  compiler-PDB path, using a second container bind mount to make that Windows
  path available to VC6 during compilation. Keeping that compiler PDB accessible
  at its recorded path still did not restore the types in DIA, vsdbg, or CDB.
  No global drive aliases were created and no PDB contents were rewritten.

This is not just evidence of a missing adjacent file. The behavior is consistent
with the historical unsupported VC6 separate-type-pool issue described in
[archived Microsoft KB318135](https://ftp.zx.net.nz/pub/archive/ftp.microsoft.com/MISC/KB/en-us/318/135.HTM).
That article applies to Visual Studio .NET 2002; the results above independently
describe the modern readers actually tested here. Do not extend the conclusion
to every debugger/version without testing it.

## Implications for the standalone repro

1. Include `/Zi` and `/Z7` rather than making the report appear `/Z7`-specific.
2. Use `/PDBTYPE:CON` for both primary builds. Each should have an untouched NB10
   and reference-only RSDS variant. This demonstrates that the NB10 failure is
   independent of whether compiler debug information originated in an OBJ or a
   compiler PDB.
3. Add the two `SEPT` builds as secondary diagnostics, documenting compiler-PDB
   dependencies and actual type availability separately from symbol discovery.
4. Test user-defined struct/pointer members, not just integers or line breakpoints.
   Basic types can remain readable when the separate type pool is unusable.
5. Do not describe `/Z7` as inherently required by the EXE-reference patch.
   `/Zi CON` is another verified self-contained input to that patch.
6. Do not bundle only the final PDB from a separate-types build and assume the
   recipient has all required debug products. Even supplying the compiler PDB
   did not make the tested modern readers support this separate-types case.
7. For the DbgEng adapter source-path contribution, select either consolidated
   original-NB10 variant as the primary integration fixture. Keep the `SEPT`
   type-inspection limitation separate from the adapter's path-resolution bug.

## Evidence and scope

The actual vsdbg tests were direct DAP sessions against the extension's bundled
adapter: stop at entry, set the local source breakpoint at `BREAK_MAIN` (line 19
in this fixture), continue to that breakpoint, inspect modules/stack/scopes/locals,
and expand `sample` when possible. The debugger reported `bias=12`, and the
successful cases exposed `sample.x=10` and `sample.y=20`. The local `result` had
not been assigned yet at that stop and was not used as a correctness assertion.

CDB independently loaded each original and RSDS variant, set the same source
breakpoint, continued, and inspected locals with `dv /t`. These were real backend
tests, not UI automation. Application code/build configuration in this repository
was not changed for the comparison.

Exploratory source, commands, transcripts, and JSON results are under
`%LOCALAPPDATA%\Temp\opencode\vc6-debug-switch-matrix` on the investigation
machine. These are temporary diagnostics, not the polished standalone package.
Some supplementary artifacts/logs contain real local paths; sanitize them before
sharing. The prompts must still produce a self-contained recipient-ready package.
