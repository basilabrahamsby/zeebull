@echo off
setlocal
echo ========================================
echo Starting TeqMates Local Environment
echo ========================================
echo.

REM Define Portable Paths
if exist "D:\flutter_portable\flutter" (
    set "FLUTTER_HOME=D:\flutter_portable\flutter"
    set "ANDROID_HOME=D:\flutter_portable\android_sdk"
    set "JAVA_HOME=D:\flutter_portable\jdk"
    set "PATH=%FLUTTER_HOME%\bin;%JAVA_HOME%\bin;%PATH%"
    echo Using portable Flutter environment.
) else (
    echo Portable Flutter not found. Using system Flutter and Java installations.
)

set "START_FLAGS="
set "CMD_ACTION=/k"
if "%HEADLESS%"=="1" (
    set "START_FLAGS=/B"
    set "CMD_ACTION=/c"
    set "BROWSER=none"
)

REM Kill existing sessions
echo [0/6] Cleaning up existing sessions...
taskkill /F /IM python.exe /T >nul 2>&1
taskkill /F /IM node.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1
echo Cleanup complete.
echo.

REM Start Backend
echo [1/6] Starting Backend...
start %START_FLAGS% "Backend (8011)" cmd %CMD_ACTION% "cd ResortApp && venv\Scripts\activate && python main.py <nul"

REM Wait for backend
ping 127.0.0.1 -n 6 >nul

REM Start Admin Dashboard
echo [2/6] Starting Admin Dashboard...
start %START_FLAGS% "Admin Dashboard (3000)" cmd %CMD_ACTION% "cd dasboard && npm start <nul"

REM Wait a bit
ping 127.0.0.1 -n 3 >nul

REM Start User End
echo [3/6] Starting User End...
start %START_FLAGS% "User End (3002)" cmd %CMD_ACTION% "cd userend && npm start <nul"

REM Start Flutter Employee App
echo [4/6] Starting Employee App...
start %START_FLAGS% "Employee App" cmd %CMD_ACTION% "cd Mobile\employee && flutter run <nul"

REM Start Flutter Owner App
echo [5/6] Starting Owner App...
start %START_FLAGS% "Owner App" cmd %CMD_ACTION% "cd Mobile\owner && flutter run <nul"

echo.
echo ========================================
echo All systems are starting!
echo Backend:  http://localhost:8011
echo Admin:    http://localhost:3000
echo User:     http://localhost:3002
echo Mobile:   Starting (using Portable Flutter)...
echo ========================================
echo.
if "%HEADLESS%"=="1" (
    echo Headless mode: Keeping script alive to maintain background services.
    pause >nul
) else (
    pause
)
