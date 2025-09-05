# HexStrike AI - Management Script Documentation

## Overview

The `hexstrike-manager.sh` script provides comprehensive setup and server management capabilities for the HexStrike AI cybersecurity automation platform. This script handles everything from initial installation to ongoing server monitoring and maintenance.

## Features

✅ **Complete Environment Setup** - Automated Python virtual environment creation and dependency installation  
✅ **Server Lifecycle Management** - Start, stop, restart, and monitor the HexStrike AI server  
✅ **System Requirements Validation** - Automatic detection and verification of required components  
✅ **MCP Client Configuration** - Automatic configuration for Claude Desktop, Cursor, and VS Code  
✅ **Security Tools Verification** - Check installation status of 150+ security tools  
✅ **Real-time Monitoring** - Live dashboard with system resources and health checks  
✅ **Backup & Restore** - Configuration backup and restore functionality  
✅ **Log Management** - Centralized logging with rotation and viewing capabilities  
✅ **macOS Integration** - LaunchAgent creation for system service integration  

## Quick Start

### 1. Initial Setup
```bash
# Make the script executable (if not already)
chmod +x hexstrike-manager.sh

# Run initial setup
./hexstrike-manager.sh setup
```

### 2. Start the Server
```bash
# Start with default settings (127.0.0.1:8888)
./hexstrike-manager.sh start

# Start with custom host/port
HOST=0.0.0.0 PORT=9000 ./hexstrike-manager.sh start
```

### 3. Check Status
```bash
# Check server status and health
./hexstrike-manager.sh status
```

## Commands Reference

### Setup and Installation
- `setup` - Performs initial setup including:
  - System requirements validation
  - Python virtual environment creation
  - Dependency installation from requirements.txt
  - Directory structure creation (logs, config, backups)
  - MCP client configuration
  - macOS LaunchAgent creation

### Server Management
- `start` - Start the HexStrike AI server
- `stop` - Gracefully stop the server (SIGTERM → SIGKILL if needed)
- `restart` - Stop and start the server
- `status` - Check server status with health endpoint testing

### Monitoring and Logs
- `logs [type]` - View logs (types: server, error)
- `monitor` - Real-time monitoring dashboard with:
  - Server status and PID
  - CPU and memory usage
  - Health endpoint response
  - System load average
  - Recent log entries

### Configuration
- `config` - Configure MCP clients for:
  - Claude Desktop (`~/.config/Claude/claude_desktop_config.json`)
  - Cursor (`.cursor/claude_desktop_config.json`)
  - Project configuration (`hexstrike-ai-mcp.json`)

### Security Tools
- `tools` - Check installation status of security tools including:
  - Network scanners (nmap, masscan, rustscan)
  - Web testing tools (gobuster, ffuf, nuclei, sqlmap)
  - Password crackers (hydra, john, hashcat)
  - Reverse engineering tools (radare2, gdb)
  - Container tools (docker, kubectl)

### Maintenance
- `backup` - Create timestamped backup of configuration
- `update` - Update Python dependencies
- `cleanup` - Clean temporary files and old logs

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST` | 127.0.0.1 | Server bind address |
| `PORT` | 8888 | Server port |

## File Structure

```
hexstrike-ai/
├── hexstrike-manager.sh          # Main management script
├── hexstrike_server.py            # HexStrike AI server
├── hexstrike_mcp.py              # MCP client interface
├── requirements.txt              # Python dependencies
├── hexstrike-ai-mcp.json         # MCP configuration
├── logs/                         # Log files
│   ├── hexstrike.log            # Main server log
│   └── error.log                # Error log
├── config/                       # Configuration files
├── backups/                      # Configuration backups
└── hexstrike-env/               # Python virtual environment
```

## Integration Examples

### Claude Desktop Integration
After running `./hexstrike-manager.sh setup`, Claude Desktop will be automatically configured with the HexStrike AI MCP server. The configuration is placed at:
```
~/.config/Claude/claude_desktop_config.json
```

### Cursor Integration  
Cursor configuration is created at:
```
.cursor/claude_desktop_config.json
```

### macOS System Integration
The script creates a LaunchAgent plist for system integration:
```bash
# Enable auto-start on login
launchctl load ~/Library/LaunchAgents/com.hexstrike.ai.plist

# Start service now
launchctl start com.hexstrike.ai

# Stop service
launchctl stop com.hexstrike.ai

# Disable auto-start
launchctl unload ~/Library/LaunchAgents/com.hexstrike.ai.plist
```

## Security Tools Installation

The script checks for 150+ security tools across categories:

### Network & Reconnaissance
- nmap, masscan, rustscan, amass, subfinder, fierce, dnsenum, theharvester

### Web Application Testing
- gobuster, feroxbuster, ffuf, nuclei, nikto, sqlmap, wpscan, katana, httpx

### Authentication & Password
- hydra, john, hashcat, medusa, patator

### Binary Analysis
- radare2, gdb, binwalk, strings, objdump

### Cloud & Container
- docker, kubectl, prowler, scout-suite, trivy

### Installation on macOS
```bash
# Install core tools via Homebrew
brew install nmap masscan gobuster ffuf nuclei sqlmap hydra john
brew install radare2 docker kubernetes-cli

# For comprehensive coverage, consider Kali Linux in VM or container
```

## Monitoring Dashboard

The `monitor` command provides a real-time dashboard showing:

```
🚀 HexStrike AI Server Status
✅ Server Status: RUNNING (PID: 12345)
ℹ️  CPU & Memory: 2.5% 45.2MB
ℹ️  Health Status: HTTP 200
ℹ️  System Load: 1.25, 1.18, 1.05

Recent log entries:
  2024-01-15 10:30:15 - Server started on 127.0.0.1:8888
  2024-01-15 10:30:16 - AI agents initialized
  2024-01-15 10:30:17 - MCP server ready
```

## Troubleshooting

### Server Won't Start
1. Check requirements: `./hexstrike-manager.sh setup`
2. Verify virtual environment exists: `ls hexstrike-env/`
3. Check logs: `./hexstrike-manager.sh logs error`
4. Verify port availability: `netstat -an | grep 8888`

### MCP Integration Issues
1. Reconfigure clients: `./hexstrike-manager.sh config`
2. Check server status: `./hexstrike-manager.sh status`
3. Verify paths in MCP configuration files
4. Restart AI client application

### Permission Issues
```bash
# Ensure script is executable
chmod +x hexstrike-manager.sh

# Check directory permissions
ls -la logs/ config/ backups/
```

### Python Environment Issues
```bash
# Recreate virtual environment
rm -rf hexstrike-env/
./hexstrike-manager.sh setup
```

## Advanced Usage

### Custom Configuration
```bash
# Start server on all interfaces with custom port
HOST=0.0.0.0 PORT=9000 ./hexstrike-manager.sh start

# Monitor with custom refresh rate (modify script)
# Change sleep 5 to desired interval in monitor_server function
```

### Automation Scripts
```bash
#!/bin/bash
# Example automation script

# Start server if not running
if ! ./hexstrike-manager.sh status > /dev/null 2>&1; then
    ./hexstrike-manager.sh start
fi

# Create daily backup
./hexstrike-manager.sh backup

# Clean up old files
./hexstrike-manager.sh cleanup
```

## Support and Resources

- **Discord**: https://discord.gg/BWnmrrSHbA
- **GitHub**: https://github.com/0x4m4/hexstrike-ai
- **Website**: https://www.hexstrike.com

## Security Considerations

⚠️ **Important Security Notes**:
- This tool provides AI agents with powerful system access
- Run in isolated environments for production testing  
- Monitor AI agent activities through the dashboard
- Consider implementing authentication for network-accessible deployments
- Only test against authorized systems with proper written permission

## Legal Notice

This tool is designed for:
- ✅ Authorized penetration testing
- ✅ Bug bounty programs (within scope)
- ✅ CTF competitions
- ✅ Security research on owned systems
- ✅ Red team exercises with approval

Never use for unauthorized testing or malicious activities.
