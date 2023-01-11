@echo off

REM ****************************************************************************
REM 
REM Author : Malcolm Smith, MJ freelancing
REM          http://www.mjfreelancing.com
REM 
REM Pre-requisites:  \Lib\Source\ZLib must contain the ZLIB OBJ files
REM                  \Lib\Packages\CB_Delphi_5 contains the project / res files
REM                  \Lib\Source contains the pas / inc files
REM 
REM ****************************************************************************

..\computil SetupC5
if exist setenv.bat call setenv.bat
if exist setenv.bat del setenv.bat > nul

if (%NDC5%)==() goto enderror
if not exist %NDC5%\bin\dcc32.exe goto endnocompiler

if not exist ..\..\..\C5\*.* md ..\..\..\C5 
if exist ..\..\..\C5\*.* call ..\clean.bat ..\..\..\C5\

copy IndySystem40.dpk ..\..\..\C5 > nul
copy *IndySystem40.cfg1 ..\..\..\C5 > nul
copy *IndySystem40.cfg2 ..\..\..\C5 > nul
copy *IndyCore40.dpk ..\..\..\C5 > nul
copy *IndyCore40.cfg1 ..\..\..\C5 > nul
copy *IndyCore40.cfg2 ..\..\..\C5 > nul
copy *IndyProtocols40.dpk ..\..\..\C5 > nul
copy *IndyProtocols40.cfg1* ..\..\..\C5 > nul
copy *IndyProtocols40.cfg2 ..\..\..\C5 > nul

cd ..\..\Source
copy zlib\*.obj ..\..\C5 > nul
copy *.res ..\..\C5 > nul
copy *.pas ..\..\C5 > nul
copy *.dcr ..\..\C5 > nul
copy *.inc ..\..\C5 > nul

cd ..\..\C5

REM ************************************************************
REM Compile IndySystem50 - Round 1
REM ************************************************************
copy IndySystem50.cfg1 IndySystem50.cfg > nul
%NDC5%\bin\dcc32.exe /B IndySystem50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile IndySystem50 - Round 2
REM ************************************************************
del IndySystem50.cfg > nul
copy IndySystem50.cfg2 IndySystem50.cfg > nul
%NDC5%\bin\dcc32.exe /B IndySystem50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Correct the LSP file (quote everything)
REM ************************************************************
..\Lib\Packages\LspFix.exe IndySystem50.lsp
%NDC5%\bin\tlib.exe IndySystem50.lib @IndySystem50.lsp /P64
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile IndyCore50 - Round 1
REM ************************************************************
copy IndyCore50.cfg1 IndyCore50.cfg > nul
%NDC5%\bin\dcc32.exe /B IndyCore50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile IndyCore50 - Round 2
REM ************************************************************
del IndyCore50.cfg > nul
copy IndyCore50.cfg2 IndyCore50.cfg > nul
%NDC5%\bin\dcc32.exe /B IndyCore50.dpk
if errorlevel 1 goto enderror2

..\Lib\Packages\LspFix.exe IndyCore50.lsp
%NDC5%\bin\tlib.exe IndyCore50.lib @IndyCore50.lsp /P64
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile dclIndyCore50 - Round 1
REM ************************************************************
copy dclIndyCore50.cfg1 dclIndyCore50.cfg > nul
%NDC5%\bin\dcc32.exe /B dclIndyCore50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile dclIndyCore50 - Round 2
REM ************************************************************
del dclIndyCore50.cfg > nul
copy dclIndyCore50.cfg2 dclIndyCore50.cfg > nul
%NDC5%\bin\dcc32.exe /B dclIndyCore50.dpk
if errorlevel 1 goto enderror2

rem ..\Lib\Packages\LspFix.exe dclIndyCore50.lsp
rem %NDC5%\bin\tlib.exe dclIndyCore50.lib @dclIndyCore50.lsp /P64
rem if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile IndyProtocols50 - Round 1a (dummy build to get headers)
REM ************************************************************
copy IndyProtocols50.cfg1a IndyProtocols50.cfg > nul
%NDC5%\bin\dcc32.exe /B IndyProtocols50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile IndyProtocols50 - Round 1b (dummy build to get headers)
REM ************************************************************
del IndyProtocols50.cfg > nul
copy IndyProtocols50.cfg1b IndyProtocols50.cfg > nul
%NDC5%\bin\dcc32.exe /B IndyProtocols50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile IndyProtocols50 - Round 2
REM ************************************************************
del IndyProtocols50.cfg > nul
copy IndyProtocols50.cfg2 IndyProtocols50.cfg > nul
%NDC5%\bin\dcc32.exe /B IndyProtocols50.dpk
if errorlevel 1 goto enderror2

..\Lib\Packages\LspFix.exe IndyProtocols50.lsp
%NDC5%\bin\tlib.exe IndyProtocols50.lib @IndyProtocols50.lsp /P64
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile dclIndyProtocols50 - Round 1
REM ************************************************************
copy dclIndyProtocols50.cfg1 dclIndyProtocols50.cfg > nul
%NDC5%\bin\dcc32.exe /B dclIndyProtocols50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Compile dclIndyProtocols50 - Round 2
REM ************************************************************
del dclIndyProtocols50.cfg > nul 
copy dclIndyProtocols50.cfg2 dclIndyProtocols50.cfg > nul
%NDC5%\bin\dcc32.exe /B dclIndyProtocols50.dpk
if errorlevel 1 goto enderror2


REM ************************************************************
REM Set all files we want to keep with the R attribute then 
REM delete the rest before restoring the attribute
REM ************************************************************
attrib +r Id*.hpp
attrib +r *.bpl
attrib +r Indy*.bpi
attrib +r Indy*.lib
attrib +r indysystem50.res
attrib +r indycore50.res
attrib +r indyprotocols50.res
del /Q /A:-R *.* > nul
attrib -r Id*.hpp
attrib -r *.bpl
attrib -r Indy*.bpi
attrib -r Indy*.lib
attrib -r indysystem50.res
attrib -r indycore50.res
attrib -r indyprotocols50.res

cd ..\Lib\Packages\CB_Delphi_5
goto endok

:enderror2
cd ..\Lib\Packages\CB_Delphi_5

:enderror
echo Error!
pause
goto endok

:endnocompiler
echo C++Builder 5 Compiler Not Present!
goto endok

:endok
