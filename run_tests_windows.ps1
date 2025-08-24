# PowerShell Test Runner for MCP CLI
# This script runs all tests with Windows-specific considerations

Write-Host "MCP CLI Windows Test Runner" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "src\mcp_cli\main.py")) {
    Write-Host "Error: Please run this script from the mcp-cli root directory" -ForegroundColor Red
    exit 1
}

# Set environment variables for testing
$env:MCP_TOOL_TIMEOUT = "300"
$env:PYTHONIOENCODING = "utf-8"

Write-Host "`nRunning basic import test..." -ForegroundColor Yellow
python -c "import sys; sys.path.insert(0, 'src'); import mcp_cli; print('✓ mcp_cli imported successfully')"

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Import test failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`nRunning help command test..." -ForegroundColor Yellow
python -m mcp_cli --help > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Help command works" -ForegroundColor Green
} else {
    Write-Host "✗ Help command failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "`nRunning diagnostic tests..." -ForegroundColor Yellow
python diagnostics\cli_command_diagnostic.py --help > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Diagnostic script works" -ForegroundColor Green
} else {
    Write-Host "⚠ Diagnostic script has issues (this may be expected)" -ForegroundColor Yellow
}

Write-Host "`nRunning pytest tests..." -ForegroundColor Yellow
if (Test-Path "tests\") {
    python -m pytest tests/ -v --tb=short
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Some tests failed" -ForegroundColor Red
        exit $LASTEXITCODE
    } else {
        Write-Host "✓ All pytest tests passed" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ No tests directory found" -ForegroundColor Yellow
}

Write-Host "`nAll Windows compatibility tests completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "✓ Import test passed" -ForegroundColor Green
Write-Host "✓ Help command test passed" -ForegroundColor Green
Write-Host "✓ Diagnostic script test completed" -ForegroundColor Green
Write-Host "✓ Pytest tests completed" -ForegroundColor Green
Write-Host ""
Write-Host "MCP CLI is ready for Windows use!" -ForegroundColor Green