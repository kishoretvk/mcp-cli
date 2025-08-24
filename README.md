# MCP CLI - Model Context Protocol Command Line Interface

A powerful, feature-rich command-line interface for interacting with Model Context Protocol servers. This client enables seamless communication with LLMs through integration with the [CHUK Tool Processor](https://github.com/chrishayuk/chuk-tool-processor) and [CHUK-LLM](https://github.com/chrishayuk/chuk-llm), providing tool usage, conversation management, and multiple operational modes.

**Default Configuration**: MCP CLI defaults to using Ollama with the `gpt-oss` reasoning model for local, privacy-focused operation without requiring API keys.

## 🔄 Architecture Overview

The MCP CLI is built on a modular architecture with clean separation of concerns:

- **[CHUK Tool Processor](https://github.com/chrishayuk/chuk-tool-processor)**: Async-native tool execution and MCP server communication
- **[CHUK-LLM](https://github.com/chrishayuk/chuk-llm)**: Unified LLM provider configuration and client management with 200+ auto-generated functions
- **MCP CLI**: Rich user interface and command orchestration (this project)

## 🌟 Features

### Multiple Operational Modes
- **Chat Mode**: Conversational interface with streaming responses and automated tool usage (default: Ollama/gpt-oss)
- **Interactive Mode**: Command-driven shell interface for direct server operations
- **Command Mode**: Unix-friendly mode for scriptable automation and pipelines
- **Direct Commands**: Run individual commands without entering interactive mode

## 🚀 Quick Start

### Installation

#### Using pip (recommended)
```bash
pip install mcp-cli
```

#### From source
```bash
git clone https://github.com/your-repo/mcp-cli.git
cd mcp-cli
pip install -e .
```

### Windows Installation

For Windows users, please see the [Windows Installation Guide](WINDOWS_INSTALLATION.md) for detailed instructions and platform-specific considerations.

### Basic Usage

```bash
# Start chat mode with default configuration
mcp-cli

# List available tools
mcp-cli tools

# List connected servers
mcp-cli servers

# Get help
mcp-cli --help
```

## 🛠️ Configuration

Create a `server_config.json` file to define your MCP servers:

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "mcp-server-sqlite",
      "args": ["--db-path", "example.db"]
    },
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["--allowed-dir", "/path/to/directory"]
    }
  }
}
```

Then use it with:
```bash
mcp-cli chat --config server_config.json
```

## 📚 Documentation

For detailed documentation, see:
- [Windows Installation Guide](WINDOWS_INSTALLATION.md) - Windows-specific installation and usage instructions
- [Commands Reference](docs/commands.md) - Complete list of available commands
- [Configuration Guide](docs/configuration.md) - Advanced configuration options
- [Server Setup](docs/servers.md) - How to set up and configure MCP servers

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Install in development mode
pip install -e .

# Run tests
pytest

# Build package
python -m build
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- **[Model Context Protocol](https://modelcontextprotocol.io/)** - Core protocol specification
- **[MCP Servers](https://github.com/modelcontextprotocol/servers)** - Official MCP server implementations
- **[CHUK Tool Processor](https://github.com/chrishayuk/chuk-tool-processor)** - Tool execution engine
- **[CHUK-LLM](https://github.com/chrishayuk/chuk-llm)** - LLM provider abstraction with GPT-5, Claude 4, O3 series support