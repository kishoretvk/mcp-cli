# Windows Installation Guide for MCP CLI

This guide provides detailed instructions for installing and using MCP CLI on Windows systems.

## Prerequisites

1. **Python 3.11 or higher** - Download from [python.org](https://www.python.org/downloads/)
2. **Git** (optional but recommended) - Download from [git-scm.com](https://git-scm.com/download/win)
3. **Microsoft Visual C++ Redistributable** (if needed for dependencies)

## Installation Methods

### Method 1: Using pip (Recommended)

```cmd
pip install mcp-cli
```

### Method 2: From Source

1. Clone the repository:
```cmd
git clone https://github.com/your-repo/mcp-cli.git
cd mcp-cli
```

2. Install in development mode:
```cmd
pip install -e .
```

### Method 3: Using uv (Fastest)

If you have [uv](https://github.com/astral-sh/uv) installed:
```cmd
uv pip install mcp-cli
```

## Windows-Specific Considerations

### PowerShell Execution Policy

If you encounter issues running PowerShell scripts, you may need to adjust your execution policy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Path Handling

MCP CLI automatically handles Windows path separators. Configuration files can use either forward slashes or backslashes:

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "mcp-server-sqlite",
      "args": ["--db-path", "C:\\Users\\YourName\\Documents\\test.db"]
    }
  }
}
```

### Terminal Compatibility

MCP CLI works with the following Windows terminals:
- Windows Terminal (recommended)
- PowerShell
- Command Prompt (cmd)
- Git Bash

## Common Issues and Solutions

### 1. "python" is not recognized

If you get "'python' is not recognized as an internal or external command", try using `python3` or `py` instead:

```cmd
py -m pip install mcp-cli
```

### 2. Permission Issues

If you encounter permission errors during installation, try:

```cmd
pip install --user mcp-cli
```

Or run the command prompt as Administrator.

### 3. Long Path Issues

Windows has a 260-character path limit by default. If you encounter issues, enable long path support:

1. Open Group Policy Editor (gpedit.msc)
2. Navigate to: Computer Configuration > Administrative Templates > System > Filesystem
3. Enable "Enable Win32 long paths"

Or set the registry key:
```
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
"LongPathsEnabled"=dword:00000001
```

## Testing the Installation

After installation, verify it works:

```cmd
mcp-cli --help
```

For development installations, you can run:
```cmd
python -m mcp_cli --help
```

## Building from Source on Windows

### Using the Batch Script

```cmd
build.bat test
```

### Using the PowerShell Script

```powershell
.\build.ps1 test
```

### Manual Build Commands

```cmd
pip install -e .
pytest
```

## Environment Variables

Set environment variables in Windows:

### Command Prompt
```cmd
set MCP_TOOL_TIMEOUT=300
set OPENAI_API_KEY=your-api-key
```

### PowerShell
```powershell
$env:MCP_TOOL_TIMEOUT="300"
$env:OPENAI_API_KEY="your-api-key"
```

## Troubleshooting

### Unicode Issues

If you encounter encoding issues, set the environment variable:
```cmd
set PYTHONIOENCODING=utf-8
```

### Signal Handling

Windows has limited signal support. MCP CLI handles this gracefully, but Ctrl+C behavior may vary between terminal applications.

### Server Executables

Ensure MCP server executables are in your PATH or specify full paths in configuration files.

## Next Steps

1. Create a server configuration file
2. Install MCP servers (e.g., `pip install mcp-server-sqlite`)
3. Test with `mcp-cli chat --config server_config.json`