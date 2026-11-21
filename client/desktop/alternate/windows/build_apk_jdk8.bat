@echo off
setlocal

set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_121
set PATH=%JAVA_HOME%\bin;%PATH%
set ANDROID_HOME=D:\Android\Sdk
set GRADLE_OPTS=

cd /d "i:\shenshou\ClientHall\AndroidProject\frameworks\runtime-src\proj.android-studio"

echo JAVA_HOME=%JAVA_HOME%
echo ANDROID_HOME=%ANDROID_HOME%
echo.

echo Running gradlew assembleRelease...
call gradlew assembleRelease --stacktrace

endlocal
pause