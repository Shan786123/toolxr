@echo off
title ToolXr — Starting...
color 0B

echo.
echo  ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██████╗
echo     ██╔══╝██╔═══██╗██╔═══██╗██║     ╚██╗██╔╝██╔══██╗
echo     ██║   ██║   ██║██║   ██║██║      ╚███╔╝ ██████╔╝
echo     ██║   ██║   ██║██║   ██║██║      ██╔██╗ ██╔══██╗
echo     ██║   ╚██████╔╝╚██████╔╝███████╗██╔╝ ██╗██║  ██║
echo     ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
echo.
echo  38 Tools · PDF · Image · Code · Convert
echo.
echo ──────────────────────────────────────────────────────
echo.

:: Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found!
    echo.
    echo  Please download and install Node.js from:
    echo  https://nodejs.org  (click the LTS button)
    echo.
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VER=%%i
echo [OK] Node.js %NODE_VER% found

:: Install dependencies if missing
if not exist "backend\node_modules" (
    echo [..] Installing backend dependencies...
    cd backend
    call npm install
    cd ..
    echo [OK] Dependencies installed
) else (
    echo [OK] Dependencies already installed
)

echo.
echo ──────────────────────────────────────────────────────
echo  Starting ToolXr backend server...
echo.
echo  Open your browser and go to:
echo  http://localhost:3001/toolxr.html
echo.
echo  Press Ctrl+C to stop the server
echo ──────────────────────────────────────────────────────
echo.

cd backend
node server.js
pause
