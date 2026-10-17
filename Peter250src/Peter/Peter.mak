# Microsoft Developer Studio Generated NMAKE File, Based on Peter.dsp
!IF "$(CFG)" == ""
CFG=Peter - Win32 Release
!MESSAGE No configuration specified. Defaulting to Peter - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "Peter - Win32 Release" && "$(CFG)" != "Peter - Win32 Debug" && "$(CFG)" != "Peter - Win32 Debug Optim"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Peter.mak" CFG="Peter - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Peter - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Peter - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "Peter - Win32 Debug Optim" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "Peter - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufIcon.obj"
	-@erase "$(INTDIR)\BufInt.obj"
	-@erase "$(INTDIR)\BufInx.obj"
	-@erase "$(INTDIR)\BufMap.obj"
	-@erase "$(INTDIR)\BufMus.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufProg.obj"
	-@erase "$(INTDIR)\BufReal.obj"
	-@erase "$(INTDIR)\BufSnd.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\BufUndo.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\EditIcon.obj"
	-@erase "$(INTDIR)\EditLog.obj"
	-@erase "$(INTDIR)\EditMap.obj"
	-@erase "$(INTDIR)\EditMus.obj"
	-@erase "$(INTDIR)\EditNum.obj"
	-@erase "$(INTDIR)\EditSnd.obj"
	-@erase "$(INTDIR)\EditSprt.obj"
	-@erase "$(INTDIR)\EditText.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\JPEG.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\ProgClip.obj"
	-@erase "$(INTDIR)\PROGCOL.OBJ"
	-@erase "$(INTDIR)\ProgDrag.obj"
	-@erase "$(INTDIR)\ProgExp.obj"
	-@erase "$(INTDIR)\ProgFile.obj"
	-@erase "$(INTDIR)\ProgHist.obj"
	-@erase "$(INTDIR)\ProgLib.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Peter.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /GS- /arch:IA32 /ML /W4 /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_OPTIM" /Fp"$(INTDIR)\Peter.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "NDEBUG" /d "_LOADER" /d "NDEMO" /d "NDEMONLITE" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\BufIcon.obj" \
	"$(INTDIR)\BufInt.obj" \
	"$(INTDIR)\BufInx.obj" \
	"$(INTDIR)\BufMap.obj" \
	"$(INTDIR)\BufMus.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufProg.obj" \
	"$(INTDIR)\BufReal.obj" \
	"$(INTDIR)\BufSnd.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\BufUndo.obj" \
	"$(INTDIR)\JPEG.obj" \
	"$(INTDIR)\EditIcon.obj" \
	"$(INTDIR)\EditLog.obj" \
	"$(INTDIR)\EditMap.obj" \
	"$(INTDIR)\EditMus.obj" \
	"$(INTDIR)\EditNum.obj" \
	"$(INTDIR)\EditSnd.obj" \
	"$(INTDIR)\EditSprt.obj" \
	"$(INTDIR)\EditText.obj" \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\ProgClip.obj" \
	"$(INTDIR)\PROGCOL.OBJ" \
	"$(INTDIR)\ProgDrag.obj" \
	"$(INTDIR)\ProgExp.obj" \
	"$(INTDIR)\ProgFile.obj" \
	"$(INTDIR)\ProgHist.obj" \
	"$(INTDIR)\ProgLib.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufIcon.obj"
	-@erase "$(INTDIR)\BufInt.obj"
	-@erase "$(INTDIR)\BufInx.obj"
	-@erase "$(INTDIR)\BufMap.obj"
	-@erase "$(INTDIR)\BufMus.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufProg.obj"
	-@erase "$(INTDIR)\BufReal.obj"
	-@erase "$(INTDIR)\BufSnd.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\BufUndo.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\EditIcon.obj"
	-@erase "$(INTDIR)\EditLog.obj"
	-@erase "$(INTDIR)\EditMap.obj"
	-@erase "$(INTDIR)\EditMus.obj"
	-@erase "$(INTDIR)\EditNum.obj"
	-@erase "$(INTDIR)\EditSnd.obj"
	-@erase "$(INTDIR)\EditSprt.obj"
	-@erase "$(INTDIR)\EditText.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\JPEG.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\ProgClip.obj"
	-@erase "$(INTDIR)\PROGCOL.OBJ"
	-@erase "$(INTDIR)\ProgDrag.obj"
	-@erase "$(INTDIR)\ProgExp.obj"
	-@erase "$(INTDIR)\ProgFile.obj"
	-@erase "$(INTDIR)\ProgHist.obj"
	-@erase "$(INTDIR)\ProgLib.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\Peter.exe"
	-@erase "$(OUTDIR)\Peter.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /GS- /arch:IA32 /MLd /W4 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /Fp"$(INTDIR)\Peter.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" /d "_LOADER" /d "NDEMO" /d "NDEMONLITE" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /debug /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\BufIcon.obj" \
	"$(INTDIR)\BufInt.obj" \
	"$(INTDIR)\BufInx.obj" \
	"$(INTDIR)\BufMap.obj" \
	"$(INTDIR)\BufMus.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufProg.obj" \
	"$(INTDIR)\BufReal.obj" \
	"$(INTDIR)\BufSnd.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\BufUndo.obj" \
	"$(INTDIR)\JPEG.obj" \
	"$(INTDIR)\EditIcon.obj" \
	"$(INTDIR)\EditLog.obj" \
	"$(INTDIR)\EditMap.obj" \
	"$(INTDIR)\EditMus.obj" \
	"$(INTDIR)\EditNum.obj" \
	"$(INTDIR)\EditSnd.obj" \
	"$(INTDIR)\EditSprt.obj" \
	"$(INTDIR)\EditText.obj" \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\ProgClip.obj" \
	"$(INTDIR)\PROGCOL.OBJ" \
	"$(INTDIR)\ProgDrag.obj" \
	"$(INTDIR)\ProgExp.obj" \
	"$(INTDIR)\ProgFile.obj" \
	"$(INTDIR)\ProgHist.obj" \
	"$(INTDIR)\ProgLib.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Peter - Win32 Debug Optim"

OUTDIR=.\DebugO
INTDIR=.\DebugO
# Begin Custom Macros
OutDir=.\DebugO
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufIcon.obj"
	-@erase "$(INTDIR)\BufInt.obj"
	-@erase "$(INTDIR)\BufInx.obj"
	-@erase "$(INTDIR)\BufMap.obj"
	-@erase "$(INTDIR)\BufMus.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufProg.obj"
	-@erase "$(INTDIR)\BufReal.obj"
	-@erase "$(INTDIR)\BufSnd.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\BufUndo.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\EditIcon.obj"
	-@erase "$(INTDIR)\EditLog.obj"
	-@erase "$(INTDIR)\EditMap.obj"
	-@erase "$(INTDIR)\EditMus.obj"
	-@erase "$(INTDIR)\EditNum.obj"
	-@erase "$(INTDIR)\EditSnd.obj"
	-@erase "$(INTDIR)\EditSprt.obj"
	-@erase "$(INTDIR)\EditText.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\JPEG.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Prog.obj"
	-@erase "$(INTDIR)\ProgClip.obj"
	-@erase "$(INTDIR)\PROGCOL.OBJ"
	-@erase "$(INTDIR)\ProgDrag.obj"
	-@erase "$(INTDIR)\ProgExp.obj"
	-@erase "$(INTDIR)\ProgFile.obj"
	-@erase "$(INTDIR)\ProgHist.obj"
	-@erase "$(INTDIR)\ProgLib.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Select.obj"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\Peter.exe"
	-@erase "$(OUTDIR)\Peter.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /GS- /arch:IA32 /MLd /W4 /Gm /Zi /O2 /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_OPTIM" /Fp"$(INTDIR)\Peter.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" /d "LOADERD" /d "NDEMO" /d "NDEMONLITE" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /debug /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\BufIcon.obj" \
	"$(INTDIR)\BufInt.obj" \
	"$(INTDIR)\BufInx.obj" \
	"$(INTDIR)\BufMap.obj" \
	"$(INTDIR)\BufMus.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufProg.obj" \
	"$(INTDIR)\BufReal.obj" \
	"$(INTDIR)\BufSnd.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\BufUndo.obj" \
	"$(INTDIR)\JPEG.obj" \
	"$(INTDIR)\EditIcon.obj" \
	"$(INTDIR)\EditLog.obj" \
	"$(INTDIR)\EditMap.obj" \
	"$(INTDIR)\EditMus.obj" \
	"$(INTDIR)\EditNum.obj" \
	"$(INTDIR)\EditSnd.obj" \
	"$(INTDIR)\EditSprt.obj" \
	"$(INTDIR)\EditText.obj" \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Select.obj" \
	"$(INTDIR)\Prog.obj" \
	"$(INTDIR)\ProgClip.obj" \
	"$(INTDIR)\PROGCOL.OBJ" \
	"$(INTDIR)\ProgDrag.obj" \
	"$(INTDIR)\ProgExp.obj" \
	"$(INTDIR)\ProgFile.obj" \
	"$(INTDIR)\ProgHist.obj" \
	"$(INTDIR)\ProgLib.obj" \
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


!IF "$(CFG)" == "Peter - Win32 Release" || "$(CFG)" == "Peter - Win32 Debug" || "$(CFG)" == "Peter - Win32 Debug Optim"
SOURCE=.\BufIcon.cpp

"$(INTDIR)\BufIcon.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufInt.cpp

"$(INTDIR)\BufInt.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufInx.cpp

"$(INTDIR)\BufInx.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufMap.cpp

"$(INTDIR)\BufMap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufMus.cpp

"$(INTDIR)\BufMus.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufPic.cpp

"$(INTDIR)\BufPic.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufProg.cpp

"$(INTDIR)\BufProg.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufReal.cpp

"$(INTDIR)\BufReal.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufSnd.cpp

"$(INTDIR)\BufSnd.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufSprt.cpp

"$(INTDIR)\BufSprt.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufText.cpp

"$(INTDIR)\BufText.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufUndo.cpp

"$(INTDIR)\BufUndo.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\JPEG.cpp

"$(INTDIR)\JPEG.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditIcon.cpp

"$(INTDIR)\EditIcon.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditLog.cpp

"$(INTDIR)\EditLog.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditMap.cpp

"$(INTDIR)\EditMap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditMus.cpp

"$(INTDIR)\EditMus.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditNum.cpp

"$(INTDIR)\EditNum.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditSnd.cpp

"$(INTDIR)\EditSnd.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditSprt.cpp

"$(INTDIR)\EditSprt.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\EditText.cpp

"$(INTDIR)\EditText.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Bitmap.cpp

"$(INTDIR)\Bitmap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Compress.cpp

"$(INTDIR)\Compress.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\File.cpp

"$(INTDIR)\File.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Main.cpp

"$(INTDIR)\Main.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\MainFrm.cpp

"$(INTDIR)\MainFrm.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Memory.cpp

"$(INTDIR)\Memory.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Stubs.c

"$(INTDIR)\Stubs.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Select.cpp

"$(INTDIR)\Select.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Prog.cpp

"$(INTDIR)\Prog.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ProgClip.cpp

"$(INTDIR)\ProgClip.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\PROGCOL.CPP

"$(INTDIR)\PROGCOL.OBJ" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ProgDrag.cpp

"$(INTDIR)\ProgDrag.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ProgExp.cpp

"$(INTDIR)\ProgExp.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ProgFile.cpp

"$(INTDIR)\ProgFile.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ProgHist.cpp

"$(INTDIR)\ProgHist.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ProgLib.cpp

"$(INTDIR)\ProgLib.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Resource.rc

"$(INTDIR)\Resource.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)



!ENDIF 

