@echo off
set DelphiProd=Delphi 10.0 Seattle

if exist SetEnv.bat del SetEnv.bat
if not exist ..\computil.exe goto NoComputil
..\computil SetupD23
if defined NDD23 goto RSVARS
if not exist SetEnv.bat goto NoNDD

call SetEnv.bat > nul:
if not defined NDD23 goto NoNDD

:RSVARS
call "%NDD23%bin\rsvars.bat"
if not defined BDS goto NoBDS

set logfn=CleanD23.log

call ..\Clean_IDE.cmd
goto END

:NoCompUtil
echo Computil.exe not found--run this batch script from the "Lib" folder of the Indy repository, recently pulled from GitHub.
goto END

:NoNDD
echo Computil.exe did not create the batch script for setting up the environment for %DelphiProd%. Aborting.
goto END

:NoBDS
echo Calling RSVars did not set up the environment for %DelphiProd%. Aborting.

:END
set logfn=
set DelphiProd=
