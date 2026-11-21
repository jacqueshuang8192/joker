@echo off
chcp 65001 >nul
echo ================================================
echo Viewing com.shenshou.game Game Logs
echo ================================================
echo.

cd /d D:\Android\Sdk\platform-tools

echo Connecting to device...
adb devices
echo.

echo ================================================
echo Clearing old logs...
echo ================================================
adb logcat -c

echo.
echo ================================================
echo Showing game logs (Press Ctrl+C to stop)
echo Filters: Game, Cocos2d, Lua, Errors, Crashes
echo ================================================
echo.

adb logcat | findstr /R /C:"com.shenshou.game" /C:"cocos2d" /C:"lua" /C:"jswrapper" /C:"AndroidRuntime" /C:"FATAL" /C:"NativeThread" /C:"Exception"
