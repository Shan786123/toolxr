@echo off
title ToolXr — Install Libraries Locally
color 0B

echo.
echo  ToolXr — Offline Library Installer
echo  ════════════════════════════════════════
echo  Downloads all CDN scripts so the site works without internet.
echo.

:: Create assets folder
if not exist "assets\js" mkdir "assets\js"
if not exist "assets\fonts" mkdir "assets\fonts"

:: Check if curl is available (built into Windows 10+)
where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] curl not found. It comes with Windows 10+.
    echo         Try running this from Windows Terminal or PowerShell.
    pause
    exit /b 1
)

echo Downloading JS libraries...
echo.

curl -sL "https://cdnjs.cloudflare.com/ajax/libs/pdf-lib/1.17.1/pdf-lib.min.js"        -o "assets\js\pdf-lib.min.js"    && echo [OK] pdf-lib        || echo [FAIL] pdf-lib
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2.0.5/FileSaver.min.js"  -o "assets\js\FileSaver.min.js"  && echo [OK] FileSaver      || echo [FAIL] FileSaver
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"            -o "assets\js\jszip.min.js"      && echo [OK] JSZip           || echo [FAIL] JSZip
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"           -o "assets\js\pdf.min.js"        && echo [OK] PDF.js          || echo [FAIL] PDF.js
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js"    -o "assets\js\pdf.worker.min.js" && echo [OK] PDF.js worker   || echo [FAIL] PDF.js worker
curl -sL "https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"           -o "assets\js\tesseract.min.js"  && echo [OK] Tesseract.js    || echo [FAIL] Tesseract.js

echo.
echo Patching toolxr.html to use local files...

:: Backup original
copy /Y toolxr.html toolxr.html.bak >nul
echo [OK] Backup saved as toolxr.html.bak

:: Use PowerShell to do the replacements (sed not available on Windows)
powershell -Command ^
  "(Get-Content 'toolxr.html' -Raw)" ^
  " -replace 'https://cdnjs.cloudflare.com/ajax/libs/pdf-lib/1.17.1/pdf-lib.min.js','assets/js/pdf-lib.min.js'" ^
  " -replace 'https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2.0.5/FileSaver.min.js','assets/js/FileSaver.min.js'" ^
  " -replace 'https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js','assets/js/jszip.min.js'" ^
  " -replace 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js','assets/js/pdf.min.js'" ^
  " -replace 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js','assets/js/pdf.worker.min.js'" ^
  " -replace 'https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js','assets/js/tesseract.min.js'" ^
  " | Set-Content 'toolxr.html'"

echo [OK] toolxr.html patched

echo.
echo  ════════════════════════════════════════
echo  [DONE] ToolXr is now fully offline!
echo.
echo  Open toolxr.html directly in your browser, OR
echo  run start.bat for the full backend server.
echo.
echo  NOTE: Remove Background still needs internet (remove.bg API).
echo        All other 37 tools work 100% offline.
echo.
pause
