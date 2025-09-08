# HexStrike AI v6.0 - Server Management Guide

## 🚀 Server Management Script

The `manage_hexstrike.sh` script provides comprehensive server management functionality for HexStrike AI.

### ✅ Current Server Status
- **Status**: ✅ Running (PID: 65147)
- **Port**: 8888
- **Tools Available**: 14/127 detected
- **Health**: Operational and responding
- **Uptime**: Fresh restart (just restarted)

---

## 📋 Available Commands

### Basic Operations

#### Start Server
```bash
./manage_hexstrike.sh start
```
- Starts the HexStrike AI server in background
- Checks for dependencies and virtual environment
- Validates startup and health endpoint
- Shows startup information and logs

#### Stop Server
```bash
./manage_hexstrike.sh stop
```
- Gracefully stops the server (SIGTERM)
- Falls back to force kill (SIGKILL) if needed
- Cleans up PID files
- Provides feedback on shutdown process

#### Restart Server
```bash
./manage_hexstrike.sh restart
```
- Combines stop + start operations
- Ensures clean shutdown before restart
- Validates new server instance
- Useful for applying configuration changes

### Monitoring & Diagnostics

#### Server Status
```bash
./manage_hexstrike.sh status
```
**Shows**:
- Process information (PID, CPU, memory, uptime)
- Health endpoint status
- Server statistics from /health endpoint
- Tool availability summary

#### View Logs
```bash
./manage_hexstrike.sh logs [number_of_lines]
```
**Examples**:
```bash
./manage_hexstrike.sh logs        # Last 50 lines (default)
./manage_hexstrike.sh logs 100    # Last 100 lines
./manage_hexstrike.sh logs 500    # Last 500 lines
```

#### Follow Logs (Real-time)
```bash
./manage_hexstrike.sh follow
```
- Live log monitoring (like `tail -f`)
- Press `Ctrl+C` to exit
- Useful for debugging and monitoring activity

#### Health Check
```bash
./manage_hexstrike.sh health
```
**Provides**:
- Complete health endpoint JSON response
- Server statistics and metrics
- Tool availability status
- Cache performance stats
- System resource usage

#### Endpoint Testing
```bash
./manage_hexstrike.sh test
```
**Tests**:
- Health endpoint (`/health`)
- AI analysis endpoint (`/api/intelligence/analyze-target`)
- Browser agent endpoint (`/api/tools/browser-agent`)
- Reports success/failure for each endpoint

---

## 🔧 Usage Examples

### Quick Health Check
```bash
# Check if server is running and healthy
./manage_hexstrike.sh status

# Output shows:
# Running (PID: 65147)
# Process Information: CPU, Memory, Uptime
# ✅ Health endpoint responding
# Server Statistics: uptime, tools, success rate
```

### Development Workflow
```bash
# Start development session
./manage_hexstrike.sh start

# Monitor logs during testing
./manage_hexstrike.sh follow

# After making changes, restart
./manage_hexstrike.sh restart

# Run endpoint tests
./manage_hexstrike.sh test
```

### Troubleshooting
```bash
# Check detailed logs
./manage_hexstrike.sh logs 200

# Check health status
./manage_hexstrike.sh health

# Test all endpoints
./manage_hexstrike.sh test

# Force restart if issues
./manage_hexstrike.sh restart
```

---

## 📊 Current Server Information

### Process Details
- **PID**: 65147 (after recent restart)
- **Port**: 8888
- **Virtual Environment**: `./hexstrike-env/`
- **Log File**: `./hexstrike_server.log`
- **Health URL**: http://localhost:8888/health

### Available Tools (14/127)
✅ **Working Tools**:
- **Web**: curl, ffuf, httpx
- **Network**: nmap, tcpdump, tshark, wireshark
- **Binary**: angr, checksec, ropgadget, objdump, strings, xxd
- **System**: file

### Server Features
- ✅ AI-powered target analysis
- ✅ Browser automation with Chrome/ChromeDriver
- ✅ 150+ security tools integration
- ✅ MCP protocol support
- ✅ Advanced error handling and recovery
- ✅ Smart caching and optimization

---

## 🔐 Security & Production Notes

### Development vs Production
- Current setup is development-focused
- For production, consider:
  - Running behind reverse proxy (nginx/apache)
  - Using systemd service for auto-restart
  - Implementing proper logging rotation
  - Securing with authentication/authorization

### Firewall Considerations
```bash
# Allow port 8888 (if needed for remote access)
sudo ufw allow 8888/tcp

# For local-only access (recommended):
# Server binds to 0.0.0.0 but can be restricted in config
```

### System Service (Optional)
```bash
# Create systemd service (Linux)
sudo cp hexstrike.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable hexstrike
sudo systemctl start hexstrike

# Manage via systemctl
sudo systemctl status hexstrike
sudo systemctl restart hexstrike
```

---

## 📞 Support & Troubleshooting

### Common Issues

**Server Won't Start**:
```bash
# Check virtual environment
ls -la hexstrike-env/

# Check dependencies
source hexstrike-env/bin/activate
pip list | grep -E "(flask|fastmcp|selenium)"

# Check logs
./manage_hexstrike.sh logs 100
```

**Health Check Fails**:
```bash
# Test connectivity
curl -v http://localhost:8888/health

# Check server process
ps aux | grep hexstrike

# Check port availability
netstat -tlpn | grep 8888
```

**Performance Issues**:
```bash
# Monitor resources
./manage_hexstrike.sh status

# Check system resources
top -p $(pgrep -f hexstrike_server)

# Review cache performance
./manage_hexstrike.sh health | grep -A5 cache_stats
```

### Log Locations
- **Setup logs**: `setup.log`
- **Server logs**: `hexstrike_server.log`
- **Management logs**: Console output from `manage_hexstrike.sh`

### Getting Help
1. Check server logs: `./manage_hexstrike.sh logs 200`
2. Run health check: `./manage_hexstrike.sh health`
3. Test endpoints: `./manage_hexstrike.sh test`
4. Review setup documentation: `SETUP_COMPLETE.md`
5. Check usage examples: `usage_examples.md`

---

*Last updated: 2025-09-04*  
*Server restarted and healthy ✅*
