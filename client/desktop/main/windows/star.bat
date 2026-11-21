@echo off
setlocal enabledelayedexpansion
set targe=''
set EXE_PATH=%~dp0

set time=2
set redirect=selfUID.lua

@echo.>count.lua
echo return 1 >> count.lua

set accoutlua=accout.lua
@echo.>%accoutlua%
echo return{ >> %accoutlua%

for /f   %%i in (accout.txt)  do (
    set target=%%i,
    echo !target! >> %accoutlua%
) 
echo } >> %accoutlua%
set /a idx=1
for /f  %%i in (accout.txt)  do (
    set debug=%%i,

    REM set debug=debug!idx!
    @echo.>!debug!.log
    echo !debug!.log
    REM set /a idx+=1
    start %EXE_PATH%\DouyouTV.exe -workdir %EXE_PATH% -scale 0.8  -console enable -write-debug-log %EXE_PATH%\!debug!.log
    TIMEOUT /T %time%
    REM del /f /s /q %redirect%
) 
TIMEOUT /T 20
 del count.lua