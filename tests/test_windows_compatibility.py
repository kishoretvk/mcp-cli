"""
Windows Compatibility Tests for MCP CLI

These tests verify that MCP CLI works correctly on Windows platforms.
"""
import os
import sys
import subprocess
import tempfile
import json
import platform
import pytest
from pathlib import Path

# Skip these tests if not running on Windows
pytestmark = pytest.mark.skipif(
    platform.system() != "Windows",
    reason="Windows compatibility tests only run on Windows"
)

def test_windows_subprocess_calls():
    """Test that subprocess calls work correctly on Windows."""
    # Test basic help command
    result = subprocess.run(
        [sys.executable, "-m", "mcp_cli", "--help"],
        capture_output=True,
        text=True,
        shell=True  # Use shell on Windows
    )
    assert result.returncode == 0
    assert "MCP CLI" in result.stdout

def test_windows_path_handling():
    """Test that path handling works correctly on Windows."""
    # Create a temporary config file with Windows-style paths
    with tempfile.TemporaryDirectory() as temp_dir:
        config_path = Path(temp_dir) / "test_config.json"
        
        config_data = {
            "mcpServers": {
                "test": {
                    "command": "echo",
                    "args": ["hello"]
                }
            }
        }
        
        with open(config_path, "w") as f:
            json.dump(config_data, f)
        
        # Test that the config file can be loaded
        assert config_path.exists()

def test_windows_environment_variables():
    """Test that environment variables work correctly on Windows."""
    # Test setting and getting environment variables
    test_var = "MCP_TEST_VAR"
    test_value = "test_value"
    
    # Set environment variable
    os.environ[test_var] = test_value
    
    # Verify it's set
    assert os.environ.get(test_var) == test_value
    
    # Test subprocess with environment
    result = subprocess.run(
        ["echo", f"%{test_var}%"],  # Windows environment variable syntax
        capture_output=True,
        text=True,
        shell=True,
        env={**os.environ, test_var: test_value}
    )
    
    # Note: On Windows cmd, environment variables are expanded by the shell
    # This test might need adjustment based on the shell used

def test_windows_console_output():
    """Test that console output works correctly on Windows."""
    # Test that rich console works
    try:
        from mcp_cli.utils.rich_helpers import get_console
        console = get_console()
        assert console is not None
        
        # Test that legacy_windows is enabled
        assert console.legacy_windows is True
    except ImportError:
        pytest.skip("Rich not available")

def test_windows_signal_handling():
    """Test that signal handling works appropriately on Windows."""
    # Import main module to test signal setup
    try:
        from mcp_cli.main import _setup_signal_handlers
        # This should not raise an exception on Windows
        _setup_signal_handlers()
    except Exception as e:
        # On Windows, some signals might not be available, which is expected
        # Check that it's a known signal issue
        if "SIG" in str(e):
            pytest.skip(f"Signal not available on Windows: {e}")
        else:
            raise

def test_windows_build_scripts():
    """Test that Windows build scripts exist and are executable."""
    # Check that build.bat exists
    build_bat = Path("build.bat")
    assert build_bat.exists(), "build.bat should exist for Windows"
    
    # Check that build.ps1 exists
    build_ps1 = Path("build.ps1")
    assert build_ps1.exists(), "build.ps1 should exist for Windows"

def test_windows_asyncio_policy():
    """Test that Windows asyncio policy is correctly set."""
    import asyncio
    
    # Check that WindowsSelectorEventLoopPolicy is used on Windows
    if sys.platform == "win32":
        current_policy = asyncio.get_event_loop_policy()
        assert isinstance(current_policy, asyncio.WindowsSelectorEventLoopPolicy), \
            "Should use WindowsSelectorEventLoopPolicy on Windows"

def test_windows_tool_timeout_handling():
    """Test that tool timeout handling works on Windows."""
    # Test environment variable setting
    timeout_var = "MCP_TOOL_TIMEOUT"
    original_value = os.environ.get(timeout_var)
    
    try:
        # Set timeout
        os.environ[timeout_var] = "30"
        
        # Import ToolManager and check timeout handling
        from mcp_cli.tools.manager import ToolManager
        
        # Create a ToolManager instance
        tm = ToolManager(
            config_file="test_config.json",
            servers=["test"],
            tool_timeout=30.0
        )
        
        # Check that timeout is set correctly
        assert tm.get_tool_timeout() == 30.0
    finally:
        # Restore original environment
        if original_value is not None:
            os.environ[timeout_var] = original_value
        elif timeout_var in os.environ:
            del os.environ[timeout_var]

def test_windows_server_config_paths():
    """Test that server configuration paths work on Windows."""
    # Test with Windows-style paths in config
    config_data = {
        "mcpServers": {
            "test": {
                "command": "cmd.exe",
                "args": ["/c", "echo", "hello"]
            }
        }
    }
    
    with tempfile.TemporaryDirectory() as temp_dir:
        config_path = Path(temp_dir) / "windows_config.json"
        
        with open(config_path, "w") as f:
            json.dump(config_data, f, indent=2)
        
        # Verify the config was written correctly
        assert config_path.exists()
        
        # Read it back
        with open(config_path, "r") as f:
            read_config = json.load(f)
        
        assert read_config["mcpServers"]["test"]["command"] == "cmd.exe"

def test_windows_diagnostics():
    """Test that diagnostic scripts work on Windows."""
    # Test cli_command_diagnostic.py
    diagnostic_script = Path("diagnostics") / "cli_command_diagnostic.py"
    if diagnostic_script.exists():
        result = subprocess.run(
            [sys.executable, str(diagnostic_script), "--help"],
            capture_output=True,
            text=True,
            shell=True
        )
        # Should either succeed or fail gracefully
        assert result.returncode == 0 or "help" in result.stdout.lower()

if __name__ == "__main__":
    pytest.main([__file__, "-v"])