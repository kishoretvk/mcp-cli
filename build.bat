@echo off
REM Windows build script for MCP CLI

setlocal

echo MCP CLI Windows Build Script
echo ===========================

REM Check if we're running from the correct directory
if not exist "src\mcp_cli\main.py" (
    echo Error: This script must be run from the project root directory
    exit /b 1
)

REM Parse command line arguments
if "%1"=="" goto help
if "%1"=="help" goto help
if "%1"=="clean" goto clean
if "%1"=="install" goto install
if "%1"=="dev-install" goto dev_install
if "%1"=="test" goto test
if "%1"=="build" goto build
if "%1"=="publish" goto publish

echo Unknown command: %1
goto help

:help
echo.
echo Available commands:
echo   clean       - Remove Python bytecode and basic artifacts
echo   install     - Install package in current environment
echo   dev-install - Install package in development mode
echo   test        - Run tests
echo   build       - Build the project
echo   publish     - Build and publish to PyPI
echo.
echo Example: build.bat test
exit /b 0

:clean
echo Cleaning Python bytecode files...
del /s /q *.pyc >nul 2>&1
del /s /q *.pyo >nul 2>&1
for /d /r %%i in (__pycache__) do if exist "%%i" rd /s /q "%%i" >nul 2>&1
for /d /r %%i in (*.egg-info) do if exist "%%i" rd /s /q "%%i" >nul 2>&1
del /s /q *.egg >nul 2>&1
echo Cleaning build artifacts...
if exist build rd /s /q build >nul 2>&1
if exist dist rd /s /q dist >nul 2>&1
if exist *.egg-info rd /s /q *.egg-info >nul 2>&1
echo Basic clean complete.
exit /b 0

:install
echo Installing package...
pip install .
exit /b %ERRORLEVEL%

:dev_install
echo Installing package in development mode...
pip install -e .
exit /b %ERRORLEVEL%

:test
echo Running tests...
where uv >nul 2>&1
if %ERRORLEVEL% == 0 (
    uv run pytest
) else (
    where pytest >nul 2>&1
    if %ERRORLEVEL% == 0 (
        pytest
    ) else (
        python -m pytest
    )
)
exit /b %ERRORLEVEL%

:build
echo Building project...
call :clean
where uv >nul 2>&1
if %ERRORLEVEL% == 0 (
    uv build
) else (
    python -m build
)
echo Build complete. Distributions are in the 'dist' folder.
exit /b %ERRORLEVEL%

:publish
echo Publishing package...
call :build
if not exist "dist" (
    echo Error: No distribution files found. Run 'build.bat build' first.
    exit /b 1
)
dir /b /o:d dist\*.tar.gz dist\*.whl 2>nul | findstr /r /c:"\.tar\.gz$" /c:"\.whl$" >nul
if %ERRORLEVEL% neq 0 (
    echo Error: No valid distribution files found.
    exit /b 1
)
REM Get the most recent files
for /f "delims=" %%i in ('dir /b /o:d dist\*.tar.gz dist\*.whl 2^>nul ^| findstr /r /c:"\.tar\.gz$" /c:"\.whl$"') do set "last_build=dist\%%i"
echo Uploading: %last_build%
twine upload %last_build%
echo Publish complete.
exit /b %ERRORLEVEL%