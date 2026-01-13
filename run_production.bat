@echo off
REM Production Launch Script for Documake
REM This script launches the application using Waitress WSGI server

echo ========================================
echo Starting Documake Production Server
echo ========================================
echo.

REM Check if virtual environment exists
if not exist venv (
    echo Error: Virtual environment not found!
    echo Please run setup_deployment.bat first to configure the deployment.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if Waitress is installed
echo Checking Waitress installation...
pip show waitress >nul 2>&1
if errorlevel 1 (
    echo Waitress not found. Installing...
    pip install waitress
    if errorlevel 1 (
        echo Error: Failed to install Waitress.
        pause
        exit /b 1
    )
)

REM Load configuration (defaults)
set HOST=0.0.0.0
set PORT=8080
set THREADS=4

if exist .env (
    echo Loading configuration from .env...
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        if "%%a"=="HOST" set HOST=%%b
        if "%%a"=="PORT" set PORT=%%b
        if "%%a"=="THREADS" set THREADS=%%b
    )
)

REM Display configuration
echo.
echo Server Configuration:
echo   Host: %HOST%
echo   Port: %PORT%
echo   Threads: %THREADS%
echo.
echo Starting Waitress server...
echo Press Ctrl+C to stop the server
echo.
echo Access the application at:
echo   http://localhost:%PORT%
echo   http://%COMPUTERNAME%:%PORT%
echo.

REM Run with Waitress
python -c "from waitress import serve; from app import app; print('Waitress server starting...'); print('Server will be available at http://%HOST%:%PORT%'); print('Press Ctrl+C to stop the server'); import sys; sys.stdout.flush(); serve(app, host='%HOST%', port=%PORT%, threads=%THREADS%, channel_timeout=120, cleanup_interval=30, asyncore_use_poll=True)"

pause

