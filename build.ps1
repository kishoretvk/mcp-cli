# PowerShell build script for MCP CLI

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

function Show-Help {
    Write-Host "MCP CLI PowerShell Build Script"
    Write-Host "=============================="
    Write-Host ""
    Write-Host "Available commands:"
    Write-Host "  clean       - Remove Python bytecode and basic artifacts"
    Write-Host "  clean-all   - Deep clean everything (pyc, build, test, cache)"
    Write-Host "  install     - Install package in current environment"
    Write-Host "  dev-install - Install package in development mode"
    Write-Host "  test        - Run tests"
    Write-Host "  build       - Build the project"
    Write-Host "  publish     - Build and publish to PyPI"
    Write-Host ""
    Write-Host "Example: .\build.ps1 test"
}

function Invoke-Clean {
    Write-Host "Cleaning Python bytecode files..."
    Get-ChildItem -Path . -Include *.pyc,*.pyo -Recurse | Remove-Item -Force
    Get-ChildItem -Path . -Directory -Recurse | Where-Object {$_.Name -eq "__pycache__"} | Remove-Item -Recurse -Force
    Get-ChildItem -Path . -Directory -Recurse | Where-Object {$_.Name -like "*.egg-info"} | Remove-Item -Recurse -Force
    Get-ChildItem -Path . -Include *.egg -Recurse | Remove-Item -Force
    Write-Host "Cleaning build artifacts..."
    if (Test-Path "build") { Remove-Item -Path "build" -Recurse -Force }
    if (Test-Path "dist") { Remove-Item -Path "dist" -Recurse -Force }
    if (Test-Path "*.egg-info") { Remove-Item -Path "*.egg-info" -Recurse -Force }
    Write-Host "Basic clean complete."
}

function Invoke-DeepClean {
    Write-Host "Deep cleaning..."
    Invoke-Clean
    if (Test-Path ".pytest_cache") { Remove-Item -Path ".pytest_cache" -Recurse -Force }
    if (Test-Path ".coverage") { Remove-Item -Path ".coverage" -Force }
    if (Test-Path "htmlcov") { Remove-Item -Path "htmlcov" -Recurse -Force }
    if (Test-Path ".tox") { Remove-Item -Path ".tox" -Recurse -Force }
    if (Test-Path ".cache") { Remove-Item -Path ".cache" -Recurse -Force }
    Get-ChildItem -Path . -Include ".coverage.*" -Recurse | Remove-Item -Force
    if (Test-Path ".mypy_cache") { Remove-Item -Path ".mypy_cache" -Recurse -Force }
    if (Test-Path ".ruff_cache") { Remove-Item -Path ".ruff_cache" -Recurse -Force }
    if (Test-Path ".uv") { Remove-Item -Path ".uv" -Recurse -Force }
    if (Test-Path "node_modules") { Remove-Item -Path "node_modules" -Recurse -Force }
    Get-ChildItem -Path . -Include ".DS_Store","Thumbs.db","*.log","*.tmp","*~" -Recurse | Remove-Item -Force
    Write-Host "Deep clean complete."
}

function Invoke-Install {
    Write-Host "Installing package..."
    pip install .
}

function Invoke-DevInstall {
    Write-Host "Installing package in development mode..."
    pip install -e .
}

function Invoke-Test {
    Write-Host "Running tests..."
    if (Get-Command "uv" -ErrorAction SilentlyContinue) {
        uv run pytest
    } elseif (Get-Command "pytest" -ErrorAction SilentlyContinue) {
        pytest
    } else {
        python -m pytest
    }
}

function Invoke-Build {
    Write-Host "Building project..."
    Invoke-Clean
    if (Get-Command "uv" -ErrorAction SilentlyContinue) {
        uv build
    } else {
        python -m build
    }
    Write-Host "Build complete. Distributions are in the 'dist' folder."
}

function Invoke-Publish {
    Write-Host "Publishing package..."
    Invoke-Build
    if (-not (Test-Path "dist")) {
        Write-Error "Error: No distribution files found. Run 'build.ps1 build' first."
        return
    }
    $distFiles = Get-ChildItem -Path "dist" -Include "*.tar.gz","*.whl"
    if ($distFiles.Count -eq 0) {
        Write-Error "Error: No valid distribution files found."
        return
    }
    # Get the most recent files
    $lastBuild = $distFiles | Sort-Object LastWriteTime | Select-Object -Last 1
    Write-Host "Uploading: $($lastBuild.FullName)"
    twine upload $lastBuild.FullName
    Write-Host "Publish complete."
}

# Main execution
switch ($Command) {
    "help" { Show-Help }
    "clean" { Invoke-Clean }
    "clean-all" { Invoke-DeepClean }
    "install" { Invoke-Install }
    "dev-install" { Invoke-DevInstall }
    "test" { Invoke-Test }
    "build" { Invoke-Build }
    "publish" { Invoke-Publish }
    default { 
        Write-Host "Unknown command: $Command"
        Show-Help
    }
}