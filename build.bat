@echo off
setlocal EnableDelayedExpansion 

echo Preparing workspace...

REM Setup path to helper bin
set ROOT_DIR="%CD%"
set RM="%CD%\bin\unxutils\rm.exe"
set CP="%CD%\bin\unxutils\cp.exe"
set MKDIR="%CD%\bin\unxutils\mkdir.exe"
set SEVEN_ZIP="%CD%\bin\7-zip\7za.exe"
set SED="%CD%\bin\unxutils\sed.exe"
set WGET="%CD%\bin\unxutils\wget.exe"
set XIDEL="%CD%\bin\xidel\xidel.exe"
set VSPC="%CD%\bin\vspc\vspc.exe"

SET arg[0]=%1
SET arg[1]=%2
SET arg[2]=%3
SET arg[3]=%4

if "!arg[0]!"=="" ( set LIBRARY_TYPE="all" )else ( set LIBRARY_TYPE=!arg[0]!)

if "!arg[1]!"=="" ( set ADRESS_MODEL=64 )else ( set ADRESS_MODEL=!arg[1]!)
rem ... or use the DEFINED keyword now
rem if defined param1 ( set ADRESS_MODEL=%1 )
if "!arg[2]!"=="" ( set TOOL_SET=msvc )else ( set TOOL_SET=!arg[2]! )
rem ... or use the DEFINED keyword now
rem if defined param2 ( set TOOL_SET=%2 )

echo Building with toolset=%TOOL_SET%, library-type=%LIBRARY_TYPE% and address-model=%ADRESS_MODEL% 

set OUTPUT_FILE = libboost_%ADRESS_MODEL%_%TOOL_SET%_%LIBRARY_TYPE%.7z

if /i "%ADRESS_MODEL%" == "32" (
	SET USER_CONFIG=%ROOT_DIR%\user-config.jam
) else (
	SET USER_CONFIG=%ROOT_DIR%\user-config64.jam
)

REM Housekeeping

RD /S /Q %ROOT_DIR%\tmp_libboost >nul 2>&1
RD /S /Q %ROOT_DIR%\third-party >nul 2>&1
RD /S /Q %ROOT_DIR%\tmp_libboost >nul 2>&1
RD /S /Q %ROOT_DIR%\third-party >nul 2>&1

DEL /Q %ROOT_DIR%\tmp_url >nul 2>&1
DEL /Q %ROOT_DIR%\boost.7z >nul 2>&1
DEL /Q %ROOT_DIR%\%OUTPUT_FILE% >nul 2>&1

REM Get download url.
echo Get download url...
%XIDEL% "http://www.boost.org/" --follow "(//div[@id='downloads']/ul/li/div/a)[3]/@href" -e "//a[text()[contains(.,'7z')]]/@href" > tmp_url

set /p url=<tmp_url

REM Download latest curl and rename to fltk.tar.gz
echo Downloading latest stable boost...
%WGET% "%url%" -O boost.7z

echo Extracting boost.7z ... (Please wait, this may take a while)
%SEVEN_ZIP% x boost.7z -y -otmp_libboost

cd %ROOT_DIR%\tmp_libboost\boost*
CALL bootstrap.bat
if /i "%LIBRARY_TYPE%" == "all" (
	set __link = static,shared
) else if /i "%LIBRARY_TYPE%" == "static" (
	set __link=static
) else if /i "%LIBRARY_TYPE%" == "shared" (
	set __link=shared
) else (
	goto usage
)

set __variant = release,debug

if /i "!arg[2]!" == "--with-python" (
	b2 install toolset=%TOOL_SET% variant=%__variant% link=%__link% threading=multi address-model=%ADRESS_MODEL% --prefix=%ROOT_DIR%\third-party\libboost --user-config=!USER_CONFIG! --with-python --abbreviate-paths --stagedir=./stage
) else if /i "!arg[2]!" == "" (
	b2 install toolset=%TOOL_SET% variant=%__variant% link=%__link% threading=multi address-model=%ADRESS_MODEL% --prefix=%ROOT_DIR%\third-party\libboost --without-python --abbreviate-paths --stagedir=./stage
) else (
	goto usage
)
REM copy files
echo Copying output files...

if /i "%LIBRARY_TYPE%" == "all" (
	cd %ROOT_DIR%\third-party\libboost\stage\lib
	%MKDIR% -p lib-release lib-debug dll-release dll-debug
	move lib*-mt-gd* lib-debug
	move lib* lib-release
	move *-mt-gd* dll-debug
	move *-mt-* dll-release
)

cd %ROOT_DIR%\third-party\libboost\include\boost*
move boost ..\tmp
cd ..
%RM% -rf boost*
ren tmp boost

cd %ROOT_DIR%\third-party
%SEVEN_ZIP% a -t7z ../%OUTPUT_FILE%  libboost

REM Cleanup temporary file/folders
cd %ROOT_DIR%
RD /S /Q %ROOT_DIR%\tmp_libboost >nul 2>&1
DEL /Q %ROOT_DIR%\tmp_url >nul 2>&1
DEL /Q %ROOT_DIR%\boost.7z >nul 2>&1

exit /b


rem ========================================================================================================
:usage
rem call :printConfiguration
ECHO: 
ECHO Error in script usage. The correct usage is:
ECHO:
ECHO     build [all^|shared^|static] - build 32 bit with msvc without python
ECHO     build [all^|shared^|static] [32^|64] compiler - build boost without python
ECHO     build [all^|shared^|static] [32^|64] compiler --with-python - build boost with python
ECHO:    
GOTO :eof
rem ========================================================================================================

:: %1 an error message
:exitB
echo:
echo Error: %1
echo:
@exit /B 0
