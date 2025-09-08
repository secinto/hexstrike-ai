# HexStrike AI v6.0 - Usage Examples

## Setup Complete ✅

### Server Status
- **Server Running**: http://localhost:8888
- **Process ID**: 94527  
- **Tools Available**: 11/127 detected
- **Browser Agent**: Active with Chrome + ChromeDriver
- **Binary Analysis**: pwntools, angr, z3-solver installed
- **MCP Integration**: Configured for Claude Desktop and VS Code/Cursor

---

## Basic Health Check

```bash
curl http://localhost:8888/health
```

**Response**: Server operational with tool availability stats and system metrics.

---

## 1. AI-Powered Target Analysis

### Basic Target Intelligence
```bash
curl -X POST http://localhost:8888/api/intelligence/analyze-target \
  -H "Content-Type: application/json" \
  -d '{"target": "example.com", "analysis_type": "comprehensive"}'
```

**Features**: 
- Target classification (web app, API, infrastructure)
- Risk assessment scoring
- Technology stack identification
- Attack surface analysis

---

## 2. Browser Agent & Web Security Testing

### Automated Browser Analysis
```bash
curl -X POST http://localhost:8888/api/tools/browser-agent \
  -H "Content-Type: application/json" \
  -d '{
    "action": "navigate", 
    "url": "https://example.com", 
    "wait_time": 3, 
    "headless": true
  }'
```

**Capabilities**:
- ✅ DOM analysis and form detection
- ✅ Security header analysis
- ✅ Console error monitoring  
- ✅ Network traffic capture
- ✅ Screenshot generation
- ✅ XSS/Clickjacking detection

### Screenshot Capture
```bash
curl -X POST http://localhost:8888/api/tools/browser-agent \
  -H "Content-Type: application/json" \
  -d '{"action": "screenshot"}'
```

### Burp Suite Alternative
```bash
curl -X POST http://localhost:8888/api/tools/burpsuite-alternative \
  -H "Content-Type: application/json" \
  -d '{
    "target": "https://example.com",
    "scan_type": "comprehensive",
    "max_depth": 3,
    "max_pages": 50
  }'
```

---

## 3. Network Reconnaissance

### Port Scanning (Nmap Integration)
```bash
curl -X POST http://localhost:8888/api/tools/run \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "nmap",
    "target": "example.com",
    "options": ["-sS", "-O", "-A", "--script=vuln"]
  }'
```

### Subdomain Discovery
```bash
curl -X POST http://localhost:8888/api/tools/run \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "subfinder", 
    "target": "example.com"
  }'
```

---

## 4. Web Application Security

### Directory Fuzzing
```bash
curl -X POST http://localhost:8888/api/tools/run \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "ffuf",
    "target": "https://example.com/FUZZ",
    "wordlist": "/usr/share/wordlists/dirb/common.txt"
  }'
```

### SQL Injection Testing
```bash
curl -X POST http://localhost:8888/api/tools/run \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "sqlmap",
    "target": "https://example.com/search?q=test",
    "options": ["--batch", "--risk=1", "--level=1"]
  }'
```

---

## 5. Binary Analysis & Reverse Engineering

### Binary Information Extraction
```bash
curl -X POST http://localhost:8888/api/tools/run \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "checksec",
    "target": "/path/to/binary"
  }'
```

### ROP Gadget Discovery
```bash
curl -X POST http://localhost:8888/api/tools/run \
  -H "Content-Type: application/json" \
  -d '{
    "tool": "ropgadget",
    "target": "/path/to/binary",
    "options": ["--binary", "/path/to/binary"]
  }'
```

---

## 6. Intelligence & Decision Making

### Tool Recommendation
```bash
curl -X POST http://localhost:8888/api/intelligence/recommend-tools \
  -H "Content-Type: application/json" \
  -d '{
    "target": "web_application",
    "objective": "vulnerability_assessment",
    "skill_level": "intermediate"
  }'
```

### Attack Chain Generation  
```bash
curl -X POST http://localhost:8888/api/intelligence/attack-chains \
  -H "Content-Type: application/json" \
  -d '{
    "target_info": {
      "type": "web_application",
      "technologies": ["php", "mysql"],
      "ports": [80, 443, 22]
    }
  }'
```

---

## 7. Error Handling & Recovery

### Parameter Optimization
```bash
curl -X POST http://localhost:8888/api/error-handling/parameter-adjustments \
  -H "Content-Type: application/json" \
  -d '{
    "tool_name": "nmap",
    "error_type": "timeout", 
    "original_params": {"-T": "4"}
  }'
```

### Alternative Tool Suggestions
```bash
curl http://localhost:8888/api/error-handling/alternative-tools?tool_name=nmap
```

---

## 8. MCP Integration Examples

Once configured with Claude Desktop or VS Code/Cursor:

### In Claude Desktop:
```
Can you scan example.com for vulnerabilities using HexStrike AI?
```

### In VS Code/Cursor:  
```
@hexstrike analyze the security of https://target.com
```

---

## Advanced Workflows

### 1. Full Web Application Assessment
1. **Intelligence Gathering**: Target analysis + subdomain discovery
2. **Reconnaissance**: Port scanning + service enumeration  
3. **Web Testing**: Directory fuzzing + vulnerability scanning
4. **Browser Analysis**: DOM inspection + security headers
5. **Reporting**: Consolidated findings with risk scoring

### 2. Binary Exploitation Workflow
1. **Static Analysis**: checksec + strings extraction
2. **Dynamic Analysis**: GDB debugging + memory analysis
3. **Exploit Development**: ROP chain generation + payload crafting
4. **Verification**: Exploit testing + success validation

### 3. CTF Automation
1. **Challenge Analysis**: File type detection + metadata extraction
2. **Tool Selection**: AI-recommended approach based on challenge type
3. **Automated Solving**: Multi-tool orchestration with fallback strategies
4. **Flag Extraction**: Pattern matching + result validation

---

## Security Notes

⚠️ **Important**: 
- Only test on systems you own or have explicit permission to test
- HexStrike AI is for authorized security testing and research only
- Some tools require additional installation (see README.md for details)
- Review all commands before execution in production environments

---

## Support & Documentation

- **Full Documentation**: See README.md
- **Tool Integration**: 150+ security tools with intelligent parameters
- **AI Capabilities**: Decision engine, error recovery, attack chain discovery
- **Browser Automation**: Headless Chrome with security analysis
- **MCP Protocol**: Claude Desktop, VS Code, Cursor integration

**Server Logs**: `tail -f hexstrike_server.log`
**Health Status**: `curl http://localhost:8888/health`
