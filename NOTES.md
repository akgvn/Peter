# Notes

* `Tran.lib` investigation:
  * Used by all projects.
  * Looks like a transcendental maths library from MSVC itself. I placed some dumpbin output next to it.
  * Bots claim it is from MSVC4.x because that was folded into the CRT library in MSVC6.
  * Looks like to get rid of it, I need to drop `/NODEFAULTLIB` - link CRT and be done with it.
    * Not exactly. Not all math functions in CRT require initialisation. Meaning, I _could_ link the CRT but still use the custom entrypoint.

# TODO

* [ ] Find some Peter-built programs to compare behaviour
  * [ ] Edit the Loader project to be able to load from arbitrary Peter samples
* [ ] Start linking CRT _without_ going through CRT's initialisation.
* [ ] Drop the custom entrypoint. This requires mapping how globals are executed (and possibly more - not sure yet).
* [ ] Can't compile under VS2022 due to some libc related issues. Investigate.

