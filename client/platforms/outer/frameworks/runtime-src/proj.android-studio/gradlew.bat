@echo off
if "%GRADLE_WRAPPER_VERSION%"=="" set GRADLE_WRAPPER_VERSION=4.10.3
set JAVA_HOME=%JAVA_HOME%
set ANDROID_HOME=%ANDROID_HOME%
set ANDROID_SDK_ROOT=%ANDROID_HOME%

where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Java is not installed or not in PATH. Please install JDK 1.8.
    exit /b 1
)

set WRAPPER_URL=https://mirrors.aliyun.com/gradle/gradle-%GRADLE_WRAPPER_VERSION%-all.zip
set WRAPPER_DIR=%~dp0gradle\wrapper
set WRAPPER_JAR=%WRAPPER_DIR%\gradle-wrapper.jar

if not exist "%WRAPPER_JAR%" (
    echo Downloading Gradle Wrapper...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%WRAPPER_URL%' -OutFile '%TEMP%\gradle-wrapper.zip'}"
    powershell -Command "& {Expand-Archive -Path '%TEMP%\gradle-wrapper.zip' -DestinationPath '%WRAPPER_DIR%' -Force; Move-Item -Path '%WRAPPER_DIR%\gradle-%GRADLE_WRAPPER_VERSION%\*' -Destination '%WRAPPER_DIR%' -Force}"
    del "%TEMP%\gradle-wrapper.zip"
)

cd /d "%~dp0"
java -cp "%WRAPPER_JAR%\" org.gradle.wrapper.GradleWrapperMain %*
