# HexStrike AI - Debian/Ubuntu Installation Guide

This directory contains comprehensive installation scripts for setting up all security tools required by HexStrike AI on Debian and Ubuntu systems.

## 📦 Installation Options

### 🚀 Quick Install (Recommended for Getting Started)
**File:** `install-essential-tools-debian.sh`
- **Time:** 10-15 minutes
- **Tools:** 50+ most essential security tools
- **Size:** ~2GB disk space
- **Use Case:** Get started quickly with core functionality

```bash
sudo ./install-essential-tools-debian.sh
```

### 🏆 Complete Install (Full Arsenal)
**File:** `install-tools-debian.sh`  
- **Time:** 30-60 minutes
- **Tools:** 150+ professional security tools
- **Size:** ~10GB disk space
- **Use Case:** Complete penetration testing laboratory

```bash
sudo ./install-tools-debian.sh
```

## 🛠️ Tools Included

### Essential Tools (Quick Install)
| Category | Tools | Examples |
|----------|-------|----------|
| **Essential Security** | 15 tools | nmap, sqlmap, hydra, john, hashcat, nikto, gobuster, ffuf, nuclei |
| **Web Application** | 15 tools | httpx, subfinder, wfuzz, whatweb, wafw00f, arjun, uro |
| **Network Recon** | 10 tools | netcat, tcpdump, wireshark, arp-scan, nbtscan, enum4linux |
| **Binary Analysis** | 10 tools | gdb, radare2, binwalk, strings, objdump, pwntools, ropper |
| **OSINT** | 5 tools | shodan, censys, theHarvester, recon-ng |
| **Forensics/CTF** | 8 tools | foremost, exiftool, steghide, volatility, scalpel |

### Complete Tools (Full Install)
| Category | Count | Description |
|----------|-------|-------------|
| **Essential Security Tools** | 25+ | Core penetration testing framework |
| **Web Application Security** | 40+ | Web application testing arsenal |
| **Network Reconnaissance** | 25+ | Network scanning and enumeration |
| **Binary Analysis & Reverse Engineering** | 25+ | Binary analysis framework |
| **Cloud Security Tools** | 20+ | Cloud infrastructure security |
| **CTF & Forensics Tools** | 20+ | Digital forensics and CTF toolkit |
| **OSINT Tools** | 20+ | Open source intelligence gathering |
| **Password & Authentication** | 12+ | Password security testing |
| **Additional Specialized** | 15+ | Wireless, mobile, and other tools |

## 🔧 System Requirements

### Supported Systems
- **Debian:** 10, 11, 12 (Buster, Bullseye, Bookworm)
- **Ubuntu:** 18.04, 20.04, 22.04, 24.04 LTS
- **Kali Linux:** 2023.x, 2024.x
- **Architecture:** x86_64 (amd64), ARM64 (partial support)

### Minimum Requirements
- **RAM:** 4GB (8GB recommended for full install)
- **Disk Space:** 5GB (15GB for full install) 
- **Network:** Stable internet connection
- **Privileges:** Root/sudo access

## 🚀 Installation Process

### 1. Clone Repository
```bash
git clone https://github.com/0x4m4/hexstrike-ai.git
cd hexstrike-ai
```

### 2. Choose Installation Type

#### Quick Install (Recommended)
```bash
sudo ./install-essential-tools-debian.sh
```

#### Complete Install
```bash
sudo ./install-tools-debian.sh
```

### 3. Monitor Installation
- Installation progress shown in real-time
- Detailed logs saved to `/tmp/hexstrike-install-*.log`
- Failed installations noted but don't stop the process

### 4. Verify Installation
```bash
# Check installed tools
./hexstrike-manager.sh tools

# Test server functionality  
./hexstrike-manager.sh start
./hexstrike-manager.sh test basic
```

## 📊 Installation Features

### ✅ Smart Installation
- **Dependency Resolution:** Automatically installs required dependencies
- **Multi-source Installation:** APT packages, Go tools, Python packages, GitHub releases
- **Error Handling:** Graceful failure handling with alternative installation methods
- **Progress Tracking:** Real-time installation progress with colored output

### 🔄 Installation Methods
1. **APT Packages:** Standard Debian/Ubuntu repository packages
2. **Go Install:** Modern Go-based security tools (gobuster, ffuf, nuclei, etc.)
3. **Python pip:** Python-based tools (sqlmap, arjun, volatility3, etc.)
4. **GitHub Releases:** Latest binary releases (feroxbuster, x8, trivy, etc.)
5. **Source Compilation:** Tools requiring compilation (custom tools, etc.)

### 📦 Additional Components
- **Wordlists:** SecLists, PayloadsAllTheThings, FuzzDB, rockyou.txt
- **Metasploit Framework:** Complete penetration testing framework
- **Ghidra:** NSA's reverse engineering suite (if Java available)
- **Burp Suite Community:** Web application security testing platform

## 🛡️ Post-Installation

### Verify Tool Coverage
```bash
# Check HexStrike AI tool status
curl http://localhost:8888/health | python3 -m json.tool

# Or use the manager
./hexstrike-manager.sh tools
```

### Expected Coverage
- **Quick Install:** 80-90% essential tool coverage
- **Complete Install:** 95%+ total tool coverage

### Start Using HexStrike AI
```bash
# Start the server
./hexstrike-manager.sh start

# Verify it's working
./hexstrike-manager.sh status

# Test the API
./hexstrike-manager.sh test basic
```

## 🔧 Troubleshooting

### Common Issues

#### 1. Permission Denied
```bash
# Ensure you're running with sudo
sudo ./install-essential-tools-debian.sh
```

#### 2. Package Not Found
```bash
# Update package lists first
sudo apt update
sudo ./install-essential-tools-debian.sh
```

#### 3. Go Tools Not Installing
```bash
# Ensure Go is properly installed
go version
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

#### 4. Network Issues
```bash
# Check internet connectivity
curl -I https://github.com
wget --spider https://pypi.org
```

### Manual Installation
If automatic installation fails, install tools manually:
```bash
# Example: Install gobuster manually
go install github.com/OJ/gobuster/v3@latest
sudo cp $HOME/go/bin/gobuster /usr/local/bin/

# Example: Install nuclei manually  
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
sudo cp $HOME/go/bin/nuclei /usr/local/bin/
```

### Log Files
Installation logs are saved for troubleshooting:
```bash
# Quick install log
tail -f /tmp/hexstrike-essential-*.log

# Full install log  
tail -f /tmp/hexstrike-install-*.log
```

## 🔄 Updating Tools

### Update Package-based Tools
```bash
sudo apt update && sudo apt upgrade
```

### Update Go-based Tools
```bash
# Update nuclei
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
sudo cp $HOME/go/bin/nuclei /usr/local/bin/

# Update other Go tools similarly
```

### Update Python Tools
```bash
pip3 install --upgrade sqlmap arjun theHarvester volatility3
```

## 🎯 Next Steps

After installation:

1. **Configure HexStrike AI:**
   ```bash
   ./hexstrike-manager.sh setup
   ./hexstrike-manager.sh start
   ```

2. **Test Installation:**
   ```bash
   ./hexstrike-manager.sh test all
   ```

3. **Setup MCP Clients:**
   - Configure Claude Desktop
   - Setup Cursor integration
   - Test AI agent connections

4. **Start Security Testing:**
   ```bash
   # Example: Test a target with HexStrike AI
   curl -X POST http://localhost:8888/api/intelligence/analyze-target \
     -H "Content-Type: application/json" \
     -d '{"target": "example.com", "analysis_type": "comprehensive"}'
   ```

## 📚 Additional Resources

- **HexStrike AI Documentation:** [Main README](README.md)
- **Manager Commands:** [Manager Guide](MANAGER_README.md)
- **API Reference:** [API Documentation](API_REFERENCE.md)
- **Tool Usage Examples:** [Examples Directory](examples/)

## 🆘 Support

If you encounter issues:

1. **Check Logs:** Review installation logs for specific errors
2. **GitHub Issues:** Report problems at [hexstrike-ai/issues](https://github.com/0x4m4/hexstrike-ai/issues)
3. **Discord Community:** Join our [Discord server](https://discord.gg/BWnmrrSHbA)
4. **Documentation:** Review the complete documentation in the repository

---

**🚀 Happy Hacking with HexStrike AI!**
