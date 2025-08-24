#!/usr/bin/env python3
import os
import sys
import shutil
sys.path.insert(0, 'src')

os.environ['MCP_TOOL_TIMEOUT'] = '300'

import subprocess

# Use shutil.which to find python executable in a cross-platform way
python_executable = shutil.which('python') or sys.executable

# Use shell=True on Windows for better compatibility
use_shell = sys.platform == "win32"

result = subprocess.run([
    python_executable, '-m', 'mcp_cli', 'chat', 
    '--config', 'test_config.json'
], env=os.environ, shell=use_shell)