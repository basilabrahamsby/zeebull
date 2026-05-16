@echo off
setlocal
echo ========================================
echo Starting TeqMates Local Environment
echo ========================================
echo.

REM Define Portable Paths
set "FLUTTER_HOME=D:\flutter_portable\flutter"
set "ANDROID_HOME=D:\flutter_portable\android_sdk"
set "JAVA_HOME=D:\flutter_portable\jdk"
set "PATH=%FLUTTER_HOME%\bin;%JAVA_HOME%\bin;%PATH%"

REM Kill existing sessions
echo [0/6] Cleaning up existing sessions...
taskkill /F /IM python.exe /T >nul 2>&1
taskkill /F /IM node.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1
echo Cleanup complete.
echo.

REM Start Backend
echo [1/6] Starting Backend...
start "Backend (8011)" cmd /k "cd ResortApp && venv\Scripts\activate && python main.py"

REM Wait for backend
ping 127.0.0.1 -n 6 >nul

REM Start Admin Dashboard
echo [2/6] Starting Admin Dashboard...
start "Admin Dashboard (3000)" cmd /k "cd dasboard && npm start"

REM Wait a bit
ping 127.0.0.1 -n 3 >nul

REM Start User End
echo [3/6] Starting User End...
start "User End (3002)" cmd /k "cd userend && npm start"

REM Start Flutter Employee App
echo [4/6] Starting Employee App...
start "Employee App" cmd /k "cd Mobile\employee && flutter run"

REM Start Flutter Owner App
echo [5/6] Starting Owner App...
start "Owner App" cmd /k "cd Mobile\owner && flutter run"

echo.
echo ========================================
echo All systems are starting!
echo Backend:  http://localhost:8011
echo Admin:    http://localhost:3000
echo User:     http://localhost:3002
echo Mobile:   Starting (using Portable Flutter)...
echo ========================================
echo.
pause
