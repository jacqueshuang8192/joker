@echo off
setlocal

set GRADLE_OPTS=
set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_121
set ANDROID_HOME=D:\Android\Sdk

cd /d "i:\shenshou\ClientHall\AndroidProject\frameworks\runtime-src\proj.android-studio"

echo Starting Gradle build...
echo JAVA_HOME=%JAVA_HOME%
echo ANDROID_HOME=%ANDROID_HOME%

for /f "delims=" %%a in ('dir /s /b "C:\Users\Admin\.gradle\wrapper\dists\gradle-4.10.3-all\gradle.bat"') do (
    set GRADLE_BAT=%%a
    goto :found
)

:found
if defined GRADLE_BAT (
    echo Found Gradle: %GRADLE_BAT%
    call "%GRADLE_BAT%" assembleRelease --stacktrace
) else (
    echo Gradle not found
    pause
    exit /b 1
)

endlocal
pause