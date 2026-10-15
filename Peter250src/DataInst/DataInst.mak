# Microsoft Developer Studio Generated NMAKE File, Based on DataInst.dsp
!IF "$(CFG)" == ""
CFG=DataInst - Win32 Release
!MESSAGE No configuration specified. Defaulting to DataInst - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "DataInst - Win32 Release" && "$(CFG)" != "DataInst - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "DataInst.mak" CFG="DataInst - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "DataInst - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "DataInst - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "DataInst - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\Setup.exe"


CLEAN :
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Setup.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /ML /W4 /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_OPTIM" /D "NDEMO" /Fp"$(INTDIR)\DataInst.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
RSC=rc.exe
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "NDEBUG" /d "NDEMO" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Setup.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib uuid.lib ..\lib\tran.lib ole32.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Setup.pdb" /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Setup.exe" 
LINK32_OBJS= \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Setup.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "DataInst - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\Setup.exe"


CLEAN :
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\Setup.exe"
	-@erase "$(OUTDIR)\Setup.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /MLd /W4 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "NDEMO" /Fp"$(INTDIR)\DataInst.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" /d "NDEMO" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Setup.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib uuid.lib ..\lib\tran.lib ole32.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Setup.pdb" /debug /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Setup.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Setup.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("DataInst.dep")
!INCLUDE "DataInst.dep"
!ELSE 
!MESSAGE Warning: cannot find "DataInst.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "DataInst - Win32 Release" || "$(CFG)" == "DataInst - Win32 Debug"
SOURCE=.\BufText.cpp

"$(INTDIR)\BufText.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Compress.cpp

"$(INTDIR)\Compress.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\File.cpp

"$(INTDIR)\File.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Main.cpp

"$(INTDIR)\Main.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Memory.cpp

"$(INTDIR)\Memory.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Stubs.c

"$(INTDIR)\Stubs.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Resource.rc

"$(INTDIR)\Resource.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)



!ENDIF 

