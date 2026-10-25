# Notes

* Turns out WinDBG, `vsdbg` (which the VSCode extension uses) AND DIA support the old PDB files. The problem is how the PDB is pointed to from the executable (NS10 vs. RSDS). Spent the afternoon researching this - now have a script rebuilding the loader executable so that the VSCode debugger can debug it.
  * I'm still not sure this would work for all executables since there's some relocation action that can happen in some cases. It works for loader so it is fine for now - but worth researching.
* In debug mode, `Loader` tries to look up some predefined paths and load a peter program. Could use a command line parameter instead to simplify the process. Need to look at what command-line related functions in `ExecTxt` let me do first.
* GPT 6.1 Sol managed to set up a debuggable Loader executable by having MSVC6 build the object files but then using VS2026 `link.exe` to link them. Otherwise, modern debuggers can't read MSVC6-built PDB files. Had to switch one compile parameter because of this to embed more source info in object files. Linker defaults are different as well. Need to read through MSVC6 / VS docs to understand the consequences fully, but this give me an easy way to debug things instead of dealing with the MSVC6 debugger.
  * I tried to get it to do the same with clang / GNU linkers - didn't work.
  * It also used VS2026 libraries instead of MSVC6 so need to try that too.
* `Tran.lib` investigation:
  * Used by all projects.
  * Looks like a transcendental maths library from MSVC itself. I placed some dumpbin output next to it.
  * Bots claim it is from MSVC4.x because that was folded into the CRT library in MSVC6.
  * Looks like to get rid of it, I need to drop `/NODEFAULTLIB` - link CRT and be done with it.
    * Not exactly. Not all math functions in CRT require initialisation. Meaning, I _could_ link the CRT but still use the custom entrypoint.

# TODO

* [ ] Decide whether to strip `_UNICODE`/`UNICODE` conditional branches from the code, because we know they're never defined.
* [ ] Read through compile parameters used in this project, then look up the alternative options for completeness (see `./docs/*-options-msvc6.txt` files).
* [ ] Find some Peter-built programs to compare behaviour
  * [ ] Edit the Loader project to be able to load from arbitrary Peter samples
* [ ] Start linking CRT _without_ going through CRT's initialisation.
* [ ] Drop the custom entrypoint. This requires mapping how globals are executed (and possibly more - not sure yet).
* [ ] Can't compile under VS2022 due to some libc related issues. Investigate.
