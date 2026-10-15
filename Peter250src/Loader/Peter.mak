# Microsoft Developer Studio Generated NMAKE File, Based on Peter.dsp
!IF "$(CFG)" == ""
CFG=Loader - Win32 Release
!MESSAGE No configuration specified. Defaulting to Loader - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "Loader - Win32 Release" && "$(CFG)" != "Loader - Win32 Debug" && "$(CFG)" != "Loader - Win32 Debug Optim" && "$(CFG)" != "Loader - Win32 Release Mini"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Peter.mak" CFG="Loader - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Loader - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Loader - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "Loader - Win32 Debug Optim" (based on "Win32 (x86) Application")
!MESSAGE "Loader - Win32 Release Mini" (based on "Win32 (x86) Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "Loader - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufD3D.obj"
	-@erase "$(INTDIR)\BufIcon.obj"
	-@erase "$(INTDIR)\BufInt.obj"
	-@erase "$(INTDIR)\BufList.obj"
	-@erase "$(INTDIR)\BufMap.obj"
	-@erase "$(INTDIR)\BufMus.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufReal.obj"
	-@erase "$(INTDIR)\BufSnd.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\BUFWIN.OBJ"
	-@erase "$(INTDIR)\BufXFile.obj"
	-@erase "$(INTDIR)\Comp.obj"
	-@erase "$(INTDIR)\CompCom.obj"
	-@erase "$(INTDIR)\CompIco.obj"
	-@erase "$(INTDIR)\CompLog.obj"
	-@erase "$(INTDIR)\CompMap.obj"
	-@erase "$(INTDIR)\CompMus.obj"
	-@erase "$(INTDIR)\CompNum.obj"
	-@erase "$(INTDIR)\CompPic.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\CompSnd.obj"
	-@erase "$(INTDIR)\CompSpr.obj"
	-@erase "$(INTDIR)\CompTxt.obj"
	-@erase "$(INTDIR)\D3DX4.obj"
	-@erase "$(INTDIR)\D3DX5.obj"
	-@erase "$(INTDIR)\D3DX6.obj"
	-@erase "$(INTDIR)\D3DX7.obj"
	-@erase "$(INTDIR)\D3DX8.obj"
	-@erase "$(INTDIR)\D3GL0.obj"
	-@erase "$(INTDIR)\D3GL1.obj"
	-@erase "$(INTDIR)\D3GL2.obj"
	-@erase "$(INTDIR)\D3NO.obj"
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\ExecCom.obj"
	-@erase "$(INTDIR)\ExecIco.obj"
	-@erase "$(INTDIR)\ExecLog.obj"
	-@erase "$(INTDIR)\ExecMap.obj"
	-@erase "$(INTDIR)\ExecMus.obj"
	-@erase "$(INTDIR)\ExecNum.obj"
	-@erase "$(INTDIR)\ExecPic.obj"
	-@erase "$(INTDIR)\ExecSnd.obj"
	-@erase "$(INTDIR)\ExecSpr.obj"
	-@erase "$(INTDIR)\ExecTxt.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\JPEG.obj"
	-@erase "$(INTDIR)\Load.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
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
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "NDEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib msacm32.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib ole32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\BufD3D.obj" \
	"$(INTDIR)\BufIcon.obj" \
	"$(INTDIR)\BufInt.obj" \
	"$(INTDIR)\BufList.obj" \
	"$(INTDIR)\BufMap.obj" \
	"$(INTDIR)\BufMus.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufReal.obj" \
	"$(INTDIR)\BufSnd.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\BUFWIN.OBJ" \
	"$(INTDIR)\BufXFile.obj" \
	"$(INTDIR)\JPEG.obj" \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\D3DX4.obj" \
	"$(INTDIR)\D3DX5.obj" \
	"$(INTDIR)\D3DX6.obj" \
	"$(INTDIR)\D3DX7.obj" \
	"$(INTDIR)\D3DX8.obj" \
	"$(INTDIR)\D3GL0.obj" \
	"$(INTDIR)\D3GL1.obj" \
	"$(INTDIR)\D3GL2.obj" \
	"$(INTDIR)\D3NO.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Comp.obj" \
	"$(INTDIR)\CompCom.obj" \
	"$(INTDIR)\CompIco.obj" \
	"$(INTDIR)\CompLog.obj" \
	"$(INTDIR)\CompMap.obj" \
	"$(INTDIR)\CompMus.obj" \
	"$(INTDIR)\CompNum.obj" \
	"$(INTDIR)\CompPic.obj" \
	"$(INTDIR)\CompSnd.obj" \
	"$(INTDIR)\CompSpr.obj" \
	"$(INTDIR)\CompTxt.obj" \
	"$(INTDIR)\Load.obj" \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\ExecCom.obj" \
	"$(INTDIR)\ExecIco.obj" \
	"$(INTDIR)\ExecLog.obj" \
	"$(INTDIR)\ExecMap.obj" \
	"$(INTDIR)\ExecMus.obj" \
	"$(INTDIR)\ExecNum.obj" \
	"$(INTDIR)\ExecPic.obj" \
	"$(INTDIR)\ExecSnd.obj" \
	"$(INTDIR)\ExecSpr.obj" \
	"$(INTDIR)\ExecTxt.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Loader - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufD3D.obj"
	-@erase "$(INTDIR)\BufIcon.obj"
	-@erase "$(INTDIR)\BufInt.obj"
	-@erase "$(INTDIR)\BufList.obj"
	-@erase "$(INTDIR)\BufMap.obj"
	-@erase "$(INTDIR)\BufMus.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufReal.obj"
	-@erase "$(INTDIR)\BufSnd.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\BUFWIN.OBJ"
	-@erase "$(INTDIR)\BufXFile.obj"
	-@erase "$(INTDIR)\Comp.obj"
	-@erase "$(INTDIR)\CompCom.obj"
	-@erase "$(INTDIR)\CompIco.obj"
	-@erase "$(INTDIR)\CompLog.obj"
	-@erase "$(INTDIR)\CompMap.obj"
	-@erase "$(INTDIR)\CompMus.obj"
	-@erase "$(INTDIR)\CompNum.obj"
	-@erase "$(INTDIR)\CompPic.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\CompSnd.obj"
	-@erase "$(INTDIR)\CompSpr.obj"
	-@erase "$(INTDIR)\CompTxt.obj"
	-@erase "$(INTDIR)\D3DX4.obj"
	-@erase "$(INTDIR)\D3DX5.obj"
	-@erase "$(INTDIR)\D3DX6.obj"
	-@erase "$(INTDIR)\D3DX7.obj"
	-@erase "$(INTDIR)\D3DX8.obj"
	-@erase "$(INTDIR)\D3GL0.obj"
	-@erase "$(INTDIR)\D3GL1.obj"
	-@erase "$(INTDIR)\D3GL2.obj"
	-@erase "$(INTDIR)\D3NO.obj"
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\ExecCom.obj"
	-@erase "$(INTDIR)\ExecIco.obj"
	-@erase "$(INTDIR)\ExecLog.obj"
	-@erase "$(INTDIR)\ExecMap.obj"
	-@erase "$(INTDIR)\ExecMus.obj"
	-@erase "$(INTDIR)\ExecNum.obj"
	-@erase "$(INTDIR)\ExecPic.obj"
	-@erase "$(INTDIR)\ExecSnd.obj"
	-@erase "$(INTDIR)\ExecSpr.obj"
	-@erase "$(INTDIR)\ExecTxt.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\JPEG.obj"
	-@erase "$(INTDIR)\Load.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
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
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib msacm32.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib ole32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /debug /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\BufD3D.obj" \
	"$(INTDIR)\BufIcon.obj" \
	"$(INTDIR)\BufInt.obj" \
	"$(INTDIR)\BufList.obj" \
	"$(INTDIR)\BufMap.obj" \
	"$(INTDIR)\BufMus.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufReal.obj" \
	"$(INTDIR)\BufSnd.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\BUFWIN.OBJ" \
	"$(INTDIR)\BufXFile.obj" \
	"$(INTDIR)\JPEG.obj" \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\D3DX4.obj" \
	"$(INTDIR)\D3DX5.obj" \
	"$(INTDIR)\D3DX6.obj" \
	"$(INTDIR)\D3DX7.obj" \
	"$(INTDIR)\D3DX8.obj" \
	"$(INTDIR)\D3GL0.obj" \
	"$(INTDIR)\D3GL1.obj" \
	"$(INTDIR)\D3GL2.obj" \
	"$(INTDIR)\D3NO.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Comp.obj" \
	"$(INTDIR)\CompCom.obj" \
	"$(INTDIR)\CompIco.obj" \
	"$(INTDIR)\CompLog.obj" \
	"$(INTDIR)\CompMap.obj" \
	"$(INTDIR)\CompMus.obj" \
	"$(INTDIR)\CompNum.obj" \
	"$(INTDIR)\CompPic.obj" \
	"$(INTDIR)\CompSnd.obj" \
	"$(INTDIR)\CompSpr.obj" \
	"$(INTDIR)\CompTxt.obj" \
	"$(INTDIR)\Load.obj" \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\ExecCom.obj" \
	"$(INTDIR)\ExecIco.obj" \
	"$(INTDIR)\ExecLog.obj" \
	"$(INTDIR)\ExecMap.obj" \
	"$(INTDIR)\ExecMus.obj" \
	"$(INTDIR)\ExecNum.obj" \
	"$(INTDIR)\ExecPic.obj" \
	"$(INTDIR)\ExecSnd.obj" \
	"$(INTDIR)\ExecSpr.obj" \
	"$(INTDIR)\ExecTxt.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Loader - Win32 Debug Optim"

OUTDIR=.\DebugO
INTDIR=.\DebugO
# Begin Custom Macros
OutDir=.\DebugO
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufD3D.obj"
	-@erase "$(INTDIR)\BufIcon.obj"
	-@erase "$(INTDIR)\BufInt.obj"
	-@erase "$(INTDIR)\BufList.obj"
	-@erase "$(INTDIR)\BufMap.obj"
	-@erase "$(INTDIR)\BufMus.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufReal.obj"
	-@erase "$(INTDIR)\BufSnd.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\BUFWIN.OBJ"
	-@erase "$(INTDIR)\BufXFile.obj"
	-@erase "$(INTDIR)\Comp.obj"
	-@erase "$(INTDIR)\CompCom.obj"
	-@erase "$(INTDIR)\CompIco.obj"
	-@erase "$(INTDIR)\CompLog.obj"
	-@erase "$(INTDIR)\CompMap.obj"
	-@erase "$(INTDIR)\CompMus.obj"
	-@erase "$(INTDIR)\CompNum.obj"
	-@erase "$(INTDIR)\CompPic.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\CompSnd.obj"
	-@erase "$(INTDIR)\CompSpr.obj"
	-@erase "$(INTDIR)\CompTxt.obj"
	-@erase "$(INTDIR)\D3DX4.obj"
	-@erase "$(INTDIR)\D3DX5.obj"
	-@erase "$(INTDIR)\D3DX6.obj"
	-@erase "$(INTDIR)\D3DX7.obj"
	-@erase "$(INTDIR)\D3DX8.obj"
	-@erase "$(INTDIR)\D3GL0.obj"
	-@erase "$(INTDIR)\D3GL1.obj"
	-@erase "$(INTDIR)\D3GL2.obj"
	-@erase "$(INTDIR)\D3NO.obj"
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\ExecCom.obj"
	-@erase "$(INTDIR)\ExecIco.obj"
	-@erase "$(INTDIR)\ExecLog.obj"
	-@erase "$(INTDIR)\ExecMap.obj"
	-@erase "$(INTDIR)\ExecMus.obj"
	-@erase "$(INTDIR)\ExecNum.obj"
	-@erase "$(INTDIR)\ExecPic.obj"
	-@erase "$(INTDIR)\ExecSnd.obj"
	-@erase "$(INTDIR)\ExecSpr.obj"
	-@erase "$(INTDIR)\ExecTxt.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\JPEG.obj"
	-@erase "$(INTDIR)\Load.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
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
RSC_PROJ=/l 0x405 /fo"$(INTDIR)\Resource.res" /d "_DEBUG" 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Peter.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib msacm32.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib ole32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /debug /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\BufD3D.obj" \
	"$(INTDIR)\BufIcon.obj" \
	"$(INTDIR)\BufInt.obj" \
	"$(INTDIR)\BufList.obj" \
	"$(INTDIR)\BufMap.obj" \
	"$(INTDIR)\BufMus.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufReal.obj" \
	"$(INTDIR)\BufSnd.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\BUFWIN.OBJ" \
	"$(INTDIR)\BufXFile.obj" \
	"$(INTDIR)\JPEG.obj" \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\D3DX4.obj" \
	"$(INTDIR)\D3DX5.obj" \
	"$(INTDIR)\D3DX6.obj" \
	"$(INTDIR)\D3DX7.obj" \
	"$(INTDIR)\D3DX8.obj" \
	"$(INTDIR)\D3GL0.obj" \
	"$(INTDIR)\D3GL1.obj" \
	"$(INTDIR)\D3GL2.obj" \
	"$(INTDIR)\D3NO.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Comp.obj" \
	"$(INTDIR)\CompCom.obj" \
	"$(INTDIR)\CompIco.obj" \
	"$(INTDIR)\CompLog.obj" \
	"$(INTDIR)\CompMap.obj" \
	"$(INTDIR)\CompMus.obj" \
	"$(INTDIR)\CompNum.obj" \
	"$(INTDIR)\CompPic.obj" \
	"$(INTDIR)\CompSnd.obj" \
	"$(INTDIR)\CompSpr.obj" \
	"$(INTDIR)\CompTxt.obj" \
	"$(INTDIR)\Load.obj" \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\ExecCom.obj" \
	"$(INTDIR)\ExecIco.obj" \
	"$(INTDIR)\ExecLog.obj" \
	"$(INTDIR)\ExecMap.obj" \
	"$(INTDIR)\ExecMus.obj" \
	"$(INTDIR)\ExecNum.obj" \
	"$(INTDIR)\ExecPic.obj" \
	"$(INTDIR)\ExecSnd.obj" \
	"$(INTDIR)\ExecSpr.obj" \
	"$(INTDIR)\ExecTxt.obj" \
	"$(INTDIR)\Resource.res"

"$(OUTDIR)\Peter.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Loader - Win32 Release Mini"

OUTDIR=.\ReleaseM
INTDIR=.\ReleaseM
# Begin Custom Macros
OutDir=.\ReleaseM
# End Custom Macros

ALL : "$(OUTDIR)\Peter.exe"


CLEAN :
	-@erase "$(INTDIR)\Bitmap.obj"
	-@erase "$(INTDIR)\BufD3D.obj"
	-@erase "$(INTDIR)\BufIcon.obj"
	-@erase "$(INTDIR)\BufInt.obj"
	-@erase "$(INTDIR)\BufList.obj"
	-@erase "$(INTDIR)\BufMap.obj"
	-@erase "$(INTDIR)\BufMus.obj"
	-@erase "$(INTDIR)\BufPic.obj"
	-@erase "$(INTDIR)\BufReal.obj"
	-@erase "$(INTDIR)\BufSnd.obj"
	-@erase "$(INTDIR)\BufSprt.obj"
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\BUFWIN.OBJ"
	-@erase "$(INTDIR)\BufXFile.obj"
	-@erase "$(INTDIR)\Comp.obj"
	-@erase "$(INTDIR)\CompCom.obj"
	-@erase "$(INTDIR)\CompIco.obj"
	-@erase "$(INTDIR)\CompLog.obj"
	-@erase "$(INTDIR)\CompMap.obj"
	-@erase "$(INTDIR)\CompMus.obj"
	-@erase "$(INTDIR)\CompNum.obj"
	-@erase "$(INTDIR)\CompPic.obj"
	-@erase "$(INTDIR)\Compress.obj"
	-@erase "$(INTDIR)\CompSnd.obj"
	-@erase "$(INTDIR)\CompSpr.obj"
	-@erase "$(INTDIR)\CompTxt.obj"
	-@erase "$(INTDIR)\D3DX4.obj"
	-@erase "$(INTDIR)\D3DX5.obj"
	-@erase "$(INTDIR)\D3DX6.obj"
	-@erase "$(INTDIR)\D3DX7.obj"
	-@erase "$(INTDIR)\D3DX8.obj"
	-@erase "$(INTDIR)\D3GL0.obj"
	-@erase "$(INTDIR)\D3GL1.obj"
	-@erase "$(INTDIR)\D3GL2.obj"
	-@erase "$(INTDIR)\D3NO.obj"
	-@erase "$(INTDIR)\Exec.obj"
	-@erase "$(INTDIR)\ExecCom.obj"
	-@erase "$(INTDIR)\ExecIco.obj"
	-@erase "$(INTDIR)\ExecLog.obj"
	-@erase "$(INTDIR)\ExecMap.obj"
	-@erase "$(INTDIR)\ExecMus.obj"
	-@erase "$(INTDIR)\ExecNum.obj"
	-@erase "$(INTDIR)\ExecPic.obj"
	-@erase "$(INTDIR)\ExecSnd.obj"
	-@erase "$(INTDIR)\ExecSpr.obj"
	-@erase "$(INTDIR)\ExecTxt.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\JPEG.obj"
	-@erase "$(INTDIR)\Load.obj"
	-@erase "$(INTDIR)\Main.obj"
	-@erase "$(INTDIR)\MainFrm.obj"
	-@erase "$(INTDIR)\Memory.obj"
	-@erase "$(INTDIR)\Resource.res"
	-@erase "$(INTDIR)\Stubs.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Peter.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /G4 /Zp4 /GS- /arch:IA32 /ML /W4 /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_OPTIM" /D "_MINI" /Fp"$(INTDIR)\Peter.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib msacm32.lib winmm.lib comdlg32.lib comctl32.lib advapi32.lib shell32.lib ole32.lib uuid.lib ..\lib\tran.lib /nologo /subsystem:windows /incremental:no /pdb:"$(OUTDIR)\Peter.pdb" /machine:I386 /nodefaultlib /out:"$(OUTDIR)\Peter.exe" 
LINK32_OBJS= \
	"$(INTDIR)\BufD3D.obj" \
	"$(INTDIR)\BufIcon.obj" \
	"$(INTDIR)\BufInt.obj" \
	"$(INTDIR)\BufList.obj" \
	"$(INTDIR)\BufMap.obj" \
	"$(INTDIR)\BufMus.obj" \
	"$(INTDIR)\BufPic.obj" \
	"$(INTDIR)\BufReal.obj" \
	"$(INTDIR)\BufSnd.obj" \
	"$(INTDIR)\BufSprt.obj" \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\BUFWIN.OBJ" \
	"$(INTDIR)\BufXFile.obj" \
	"$(INTDIR)\JPEG.obj" \
	"$(INTDIR)\Bitmap.obj" \
	"$(INTDIR)\Compress.obj" \
	"$(INTDIR)\D3DX4.obj" \
	"$(INTDIR)\D3DX5.obj" \
	"$(INTDIR)\D3DX6.obj" \
	"$(INTDIR)\D3DX7.obj" \
	"$(INTDIR)\D3DX8.obj" \
	"$(INTDIR)\D3GL0.obj" \
	"$(INTDIR)\D3GL1.obj" \
	"$(INTDIR)\D3GL2.obj" \
	"$(INTDIR)\D3NO.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Main.obj" \
	"$(INTDIR)\MainFrm.obj" \
	"$(INTDIR)\Memory.obj" \
	"$(INTDIR)\Stubs.obj" \
	"$(INTDIR)\Comp.obj" \
	"$(INTDIR)\CompCom.obj" \
	"$(INTDIR)\CompIco.obj" \
	"$(INTDIR)\CompLog.obj" \
	"$(INTDIR)\CompMap.obj" \
	"$(INTDIR)\CompMus.obj" \
	"$(INTDIR)\CompNum.obj" \
	"$(INTDIR)\CompPic.obj" \
	"$(INTDIR)\CompSnd.obj" \
	"$(INTDIR)\CompSpr.obj" \
	"$(INTDIR)\CompTxt.obj" \
	"$(INTDIR)\Load.obj" \
	"$(INTDIR)\Exec.obj" \
	"$(INTDIR)\ExecCom.obj" \
	"$(INTDIR)\ExecIco.obj" \
	"$(INTDIR)\ExecLog.obj" \
	"$(INTDIR)\ExecMap.obj" \
	"$(INTDIR)\ExecMus.obj" \
	"$(INTDIR)\ExecNum.obj" \
	"$(INTDIR)\ExecPic.obj" \
	"$(INTDIR)\ExecSnd.obj" \
	"$(INTDIR)\ExecSpr.obj" \
	"$(INTDIR)\ExecTxt.obj" \
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


!IF "$(CFG)" == "Loader - Win32 Release" || "$(CFG)" == "Loader - Win32 Debug" || "$(CFG)" == "Loader - Win32 Debug Optim" || "$(CFG)" == "Loader - Win32 Release Mini"
SOURCE=.\BufD3D.cpp

"$(INTDIR)\BufD3D.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufIcon.cpp

"$(INTDIR)\BufIcon.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufInt.cpp

"$(INTDIR)\BufInt.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufList.cpp

"$(INTDIR)\BufList.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufMap.cpp

"$(INTDIR)\BufMap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufMus.cpp

"$(INTDIR)\BufMus.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufPic.cpp

"$(INTDIR)\BufPic.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufReal.cpp

"$(INTDIR)\BufReal.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufSnd.cpp

"$(INTDIR)\BufSnd.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufSprt.cpp

"$(INTDIR)\BufSprt.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufText.cpp

"$(INTDIR)\BufText.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BUFWIN.CPP

"$(INTDIR)\BUFWIN.OBJ" : $(SOURCE) "$(INTDIR)"


SOURCE=.\BufXFile.cpp

"$(INTDIR)\BufXFile.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\JPEG.cpp

"$(INTDIR)\JPEG.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Bitmap.cpp

"$(INTDIR)\Bitmap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Compress.cpp

"$(INTDIR)\Compress.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3DX4.cpp

"$(INTDIR)\D3DX4.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3DX5.cpp

"$(INTDIR)\D3DX5.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3DX6.cpp

"$(INTDIR)\D3DX6.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3DX7.cpp

"$(INTDIR)\D3DX7.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3DX8.cpp

"$(INTDIR)\D3DX8.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3GL0.cpp

"$(INTDIR)\D3GL0.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3GL1.cpp

"$(INTDIR)\D3GL1.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3GL2.cpp

"$(INTDIR)\D3GL2.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\D3NO.cpp

"$(INTDIR)\D3NO.obj" : $(SOURCE) "$(INTDIR)"


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


SOURCE=.\Comp.cpp

"$(INTDIR)\Comp.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompCom.cpp

"$(INTDIR)\CompCom.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompIco.cpp

"$(INTDIR)\CompIco.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompLog.cpp

"$(INTDIR)\CompLog.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompMap.cpp

"$(INTDIR)\CompMap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompMus.cpp

"$(INTDIR)\CompMus.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompNum.cpp

"$(INTDIR)\CompNum.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompPic.cpp

"$(INTDIR)\CompPic.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompSnd.cpp

"$(INTDIR)\CompSnd.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompSpr.cpp

"$(INTDIR)\CompSpr.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\CompTxt.cpp

"$(INTDIR)\CompTxt.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Resource.rc

"$(INTDIR)\Resource.res" : $(SOURCE) "$(INTDIR)"
	$(RSC) $(RSC_PROJ) $(SOURCE)


SOURCE=.\Load.cpp

"$(INTDIR)\Load.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\Exec.cpp

"$(INTDIR)\Exec.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecCom.cpp

"$(INTDIR)\ExecCom.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecIco.cpp

"$(INTDIR)\ExecIco.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecLog.cpp

"$(INTDIR)\ExecLog.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecMap.cpp

"$(INTDIR)\ExecMap.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecMus.cpp

"$(INTDIR)\ExecMus.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecNum.cpp

"$(INTDIR)\ExecNum.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecPic.cpp

"$(INTDIR)\ExecPic.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecSnd.cpp

"$(INTDIR)\ExecSnd.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecSpr.cpp

"$(INTDIR)\ExecSpr.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ExecTxt.cpp

"$(INTDIR)\ExecTxt.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

