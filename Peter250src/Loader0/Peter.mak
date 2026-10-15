# Microsoft Developer Studio Generated NMAKE File, Based on Peter.dsp
!IF "$(CFG)" == ""
CFG=Loader0 - Win32 Release
!MESSAGE No configuration specified. Defaulting to Loader0 - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "Loader0 - Win32 Release" && "$(CFG)" != "Loader0 - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Peter.mak" CFG="Loader0 - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Loader0 - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Loader0 - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "Loader0 - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Peter.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /ML /W4 /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_OPTIM" /Fp"$(INTDIR)\Peter.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32 
RSC=rc.exe
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Loader0 - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\Peter.exe"
	-@erase "$(OUTDIR)\Peter.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /MLd /W4 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /Fp"$(INTDIR)\Peter.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

MTL=midl.exe
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32 
RSC=rc.exe
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /debug /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("Peter.dep")
!INCLUDE "Peter.dep"
!ELSE 
!MESSAGE Warning: cannot find "Peter.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "Loader0 - Win32 Release" || "$(CFG)" == "Loader0 - Win32 Debug"
SOURCE=.\Main.cpp

"$(INTDIR)\Main.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Resource.RC

"$(INTDIR)\Resource.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)



!ENDIF 

