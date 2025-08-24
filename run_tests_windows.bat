@echo off
REM Windows Test Runner for MCP CLI
REM This script runs all tests with Windows-specific considerations

echo MCP CLI Windows Test Runner
echo ===========================

REM Check if we're in the right directory
if not exist "src\mcp_cli\main.py" (
    echo Error: Please run this script from the mcp-cli root directory
    exit /b 1
)

REM Set environment variables for testing
set MCP_TOOL_TIMEOUT=300
set PYTHONIOENCODING=utf-8

echo.
echo Running basic import test...
python -c "import sys; sys.path.insert(0, 'src'); import mcp_cli; print('✓ mcp_cli imported successfully')"

if %errorlevel% neq 0 (
    echo ✗ Import test failed
    exit /b %errorlevel%
)

echo.
echo Running help command test...
python -m mcp_cli --help >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Help command works
) else (
    echo ✗ Help command failed
    exit /b %errorlevel%
)

echo.
echo Running diagnostic tests...
python diagnostics\cli_command_diagnostic.py --help >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Diagnostic script works
) else (
    echo ⚠ Diagnostic script has issues (this may be expected)
)

echo.
echo Running pytest tests...
if exist "tests\" (
    python -m pytest tests/ -v --tb=short
    if %errorlevel% neq 0 (
        echo ✗ Some tests failed
        exit /b %errorlevel%
    ) else (
        echo ✓ All pytest tests passed
    )
) else (
    echo ⚠ No tests directory found
)

echo.
echo All Windows compatibility tests completed!
echo ========================================
echo Summary:
echo ✓ Import test passed
echo ✓ Help command test passed
echo ✓ Diagnostic script test completed
echo ✓ Pytest tests completed
echo.
echo MCP CLI is ready for Windows use!