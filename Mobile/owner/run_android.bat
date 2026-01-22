@echo off
echo ===================================================
echo Orchid Owner App - Android Launcher
echo ===================================================

echo 1. Launching Emulator (Pixel_7)...
call flutter emulators --launch Pixel_7

echo 2. Waiting for device to be ready...
:WAIT_LOOP
timeout /t 5 >nul
flutter devices | findstr "android" >nul
if %ERRORLEVEL% EQU 0 goto DEVICE_FOUND
echo    - Still waiting for emulator...
goto WAIT_LOOP

:DEVICE_FOUND
echo 3. Device found! Starting Application...
call flutter run

pause
