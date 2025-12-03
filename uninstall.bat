@echo off
REM Redragon-K530-ArrowFix - Uninstaller
SETLOCAL

:: Config
set "TASKNAME=RDK530RGB-ArrowFix"
set "TARGET_DIR=%~dp0"
set "TARGET_NO_SLASH=%TARGET_DIR:~0,-1%"

:: Elevate if necessary
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Requesting administrative privileges...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

:: Stop & delete scheduled task (ignore errors)
schtasks /end /tn "%TASKNAME%" >nul 2>&1
schtasks /delete /tn "%TASKNAME%" /f >nul 2>&1
echo DELETED AUTO-STARTUP

:: Show big red warning and wait for ENTER to proceed
REM Save current color by not changing it permanently; we'll reset to default after prompt.
color 0C
echo.
echo **************************************************************
echo WARNING: This will PERMANENTLY DELETE the application folder:
echo    %TARGET_DIR%
echo INCLUDING ALL FILES AND DATA. THIS ACTION IS IRREVERSIBLE.
echo.
echo Press ENTER to DELETE EVERYTHING, or Ctrl+C to cancel.
echo **************************************************************
echo.
pause >nul
color

:: Confirm again briefly (optional safety) -- proceed to schedule deletion
echo Scheduling full deletion...

REM Start a detached PowerShell to delete the folder after a short delay.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process -WindowStyle Hidden -FilePath powershell -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-Command'," ^
  "'Start-Sleep -Seconds 3; Remove-Item -LiteralPath ''%TARGET_NO_SLASH%'' -Recurse -Force -ErrorAction SilentlyContinue'"

if errorlevel 1 (
  echo Failed to start cleanup process. You may need to delete the folder manually.
  pause
  exit /b 1
)

echo Uninstaller exiting. Folder will be removed shortly.
ENDLOCAL
exit /b 0
