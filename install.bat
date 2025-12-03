@echo off
SETLOCAL

set "TASKNAME=Redragon-K530-ArrowFix"
set "BASEDIR=%~dp0"
set "VENV_DIR=%BASEDIR%venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
set "VENV_PYW=%VENV_DIR%\Scripts\pythonw.exe"
set "SCRIPT=%BASEDIR%arrow_layer.pyw"
set "REQ_FILE=%BASEDIR%requirements.txt"
set "TMPFILE=%TEMP%\rdk_inst_tmp.txt"

:: Elevation
echo [1/7] Checking admin rights...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Elevating installer...
    powershell -NoProfile -WindowStyle Hidden -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: Find Python
echo [2/7] Locating Python...
set "PY_EXE="
py -3 -c "import sys;print(sys.executable)" >"%TMPFILE%" 2>nul
if exist "%TMPFILE%" (
    set /p PY_EXE=<"%TMPFILE%"
    del "%TMPFILE%" >nul
)
if "%PY_EXE%"=="" (
    python -c "import sys;print(sys.executable)" >"%TMPFILE%" 2>nul
    if exist "%TMPFILE%" (
        set /p PY_EXE=<"%TMPFILE%"
        del "%TMPFILE%" >nul
    )
)
if "%PY_EXE%"=="" (
    echo ERROR: Python not found.
    exit /b 1
)

:: Create venv
echo [3/7] Creating virtual environment (if needed)...
if not exist "%VENV_PY%" (
    "%PY_EXE%" -m venv "%VENV_DIR%" >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment.
        exit /b 2
    )
)

:: Install requirements
echo [4/7] Installing required packages...
if exist "%REQ_FILE%" (
    "%VENV_PY%" -m pip install -r "%REQ_FILE%" >nul 2>&1
) else (
    "%VENV_PY%" -m pip install keyboard pystray Pillow >nul 2>&1
)
if errorlevel 1 (
    echo ERROR: Package installation failed.
    exit /b 3
)

:: Verify script
echo [5/7] Verifying script file...
if not exist "%SCRIPT%" (
    echo ERROR: Script file missing: %SCRIPT%
    exit /b 4
)

:: Create scheduled task
echo [6/7] Creating scheduled task...
schtasks /create /sc ONLOGON /tn "%TASKNAME%" /tr "\"%VENV_PYW%\" \"%SCRIPT%\"" /RL HIGHEST /F >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to create scheduled task.
    exit /b 5
)

:: Run task now
echo [7/7] Starting task now...
schtasks /run /tn "%TASKNAME%" >nul 2>&1

echo Done.
ENDLOCAL
exit /b 0
