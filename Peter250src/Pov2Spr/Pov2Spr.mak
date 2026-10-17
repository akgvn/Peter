# Microsoft Developer Studio Generated NMAKE File, Based on Pov2Spr.dsp
!IF "$(CFG)" == ""
CFG=Pov2Spr - Win32 Debug
!MESSAGE No configuration specified. Defaulting to Pov2Spr - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Pov2Spr - Win32 Release" && "$(CFG)" != "Pov2Spr - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Pov2Spr.mak" CFG="Pov2Spr - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Pov2Spr - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "Pov2Spr - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "Pov2Spr - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\Pov2Spr.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Pov2Spr.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /GS- /arch:IA32 /ML /W4 /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_OPTIM" /Fp"$(INTDIR)\Pov2Spr.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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

RSC=rc.exe
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Pov2Spr.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ..\lib\tran.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\Pov2Spr.pdb" /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Pov2Spr.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Pov2Spr.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Pov2Spr - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\Pov2Spr.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\Pov2Spr.exe"
	-@erase "$(OUTDIR)\Pov2Spr.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /GS- /arch:IA32 /MLd /W4 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /Fp"$(INTDIR)\Pov2Spr.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

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

RSC=rc.exe
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Pov2Spr.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ..\lib\tran.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\Pov2Spr.pdb" /debug /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Pov2Spr.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Pov2Spr.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("Pov2Spr.dep")
!INCLUDE "Pov2Spr.dep"
!ELSE 
!MESSAGE Warning: cannot find "Pov2Spr.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "Pov2Spr - Win32 Release" || "$(CFG)" == "Pov2Spr - Win32 Debug"
SOURCE=.\Bitmap.cpp

"$(INTDIR)\Bitmap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufPic.cpp

"$(INTDIR)\BufPic.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufSprt.cpp

"$(INTDIR)\BufSprt.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufText.cpp

"$(INTDIR)\BufText.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=..\Peter\Compress.cpp

"$(INTDIR)\Compress.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


SOURCE=.\File.cpp

"$(INTDIR)\File.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Main.cpp

"$(INTDIR)\Main.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Memory.cpp

"$(INTDIR)\Memory.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Resource.rc

"$(INTDIR)\Resource.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)


SOURCE=.\Stubs.c

"$(INTDIR)\Stubs.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

