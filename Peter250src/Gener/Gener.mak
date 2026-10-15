# Microsoft Developer Studio Generated NMAKE File, Based on Gener.dsp
!IF "$(CFG)" == ""
CFG=Gener - Win32 Debug
!MESSAGE No configuration specified. Defaulting to Gener - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Gener - Win32 Release" && "$(CFG)" != "Gener - Win32 Debug" && "$(CFG)" != "Gener - Win32 Install" && "$(CFG)" != "Gener - Win32 Release MINI"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Gener.mak" CFG="Gener - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Gener - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "Gener - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "Gener - Win32 Install" (based on "Win32 (x86) Console Application")
!MESSAGE "Gener - Win32 Release MINI" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF  "$(CFG)" == "Gener - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\Gener.exe"


CLEAN :
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Gener.obj"
	-@erase "$(INTDIR)\Gener.pch"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Gener.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "NINSTAL" /Fp"$(INTDIR)\Gener.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Gener.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\Gener.pdb" /machine:I386 /out:"$(OUTDIR)\Gener.exe" 
LINK32_OBJS= \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Gener.obj" \
	"$(INTDIR)\StdAfx.obj"

"$(OUTDIR)\Gener.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Gener - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\Gener.exe" "$(OUTDIR)\Gener.pch"


CLEAN :
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Gener.obj"
	-@erase "$(INTDIR)\Gener.pch"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\Gener.exe"
	-@erase "$(OUTDIR)\Gener.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MLd /W3 /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "NINSTALL" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

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
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Gener.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\Gener.pdb" /debug /machine:I386 /out:"$(OUTDIR)\Gener.exe" /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Gener.obj" \
	"$(INTDIR)\StdAfx.obj"

"$(OUTDIR)\Gener.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Gener - Win32 Install"

OUTDIR=.\Install
INTDIR=.\Install
# Begin Custom Macros
OutDir=.\Install
# End Custom Macros

ALL : "$(OUTDIR)\Gener.exe"


CLEAN :
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Gener.obj"
	-@erase "$(INTDIR)\Gener.pch"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Gener.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "_INSTALL" /Fp"$(INTDIR)\Gener.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Gener.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\Gener.pdb" /machine:I386 /out:"$(OUTDIR)\Gener.exe" 
LINK32_OBJS= \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Gener.obj" \
	"$(INTDIR)\StdAfx.obj"

"$(OUTDIR)\Gener.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Gener - Win32 Release MINI"

OUTDIR=.\Release_MINI
INTDIR=.\Release_MINI
# Begin Custom Macros
OutDir=.\Release_MINI
# End Custom Macros

ALL : "$(OUTDIR)\Gener.exe"


CLEAN :
	-@erase "$(INTDIR)\BufText.obj"
	-@erase "$(INTDIR)\File.obj"
	-@erase "$(INTDIR)\Gener.obj"
	-@erase "$(INTDIR)\Gener.pch"
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\Gener.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "NINSTAL" /D "MINI" /Fp"$(INTDIR)\Gener.pch" /Yu"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

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
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Gener.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\Gener.pdb" /machine:I386 /out:"$(OUTDIR)\Gener.exe" 
LINK32_OBJS= \
	"$(INTDIR)\BufText.obj" \
	"$(INTDIR)\File.obj" \
	"$(INTDIR)\Gener.obj" \
	"$(INTDIR)\StdAfx.obj"

"$(OUTDIR)\Gener.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("Gener.dep")
!INCLUDE "Gener.dep"
!ELSE 
!MESSAGE Warning: cannot find "Gener.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "Gener - Win32 Release" || "$(CFG)" == "Gener - Win32 Debug" || "$(CFG)" == "Gener - Win32 Install" || "$(CFG)" == "Gener - Win32 Release MINI"
SOURCE=.\BufText.cpp

"$(INTDIR)\BufText.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\Gener.pch"


SOURCE=.\File.cpp

"$(INTDIR)\File.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\Gener.pch"


SOURCE=.\Gener.cpp

"$(INTDIR)\Gener.obj" : $(SOURCE) "$(INTDIR)" "$(INTDIR)\Gener.pch"


SOURCE=.\StdAfx.cpp

!IF  "$(CFG)" == "Gener - Win32 Release"

CPP_SWITCHES=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "NINSTAL" /Fp"$(INTDIR)\Gener.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\Gener.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "Gener - Win32 Debug"

CPP_SWITCHES=/nologo /MLd /W3 /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "NINSTALL" /Fp"$(INTDIR)\Gener.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\Gener.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "Gener - Win32 Install"

CPP_SWITCHES=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "_INSTALL" /Fp"$(INTDIR)\Gener.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\Gener.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ELSEIF  "$(CFG)" == "Gener - Win32 Release MINI"

CPP_SWITCHES=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /D "NDEMO" /D "NINSTAL" /D "MINI" /Fp"$(INTDIR)\Gener.pch" /Yc"stdafx.h" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

"$(INTDIR)\StdAfx.obj"	"$(INTDIR)\Gener.pch" : $(SOURCE) "$(INTDIR)"
	$(CPP) @<<
  $(CPP_SWITCHES) $(SOURCE)
<<


!ENDIF 


!ENDIF 

