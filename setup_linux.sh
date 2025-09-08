#!/bin/bash
set -e

# HexStrike AI v6.0 - Linux Setup Script
# Advanced Cybersecurity Automation Platform
# Author: HexStrike Team
# License: MIT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
HEXSTRIKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${HEXSTRIKE_DIR}/hexstrike-env"
DEFAULT_PORT=8888
PYTHON_MIN_VERSION="3.8"
LOG_FILE="${HEXSTRIKE_DIR}/setup.log"

# Banner
show_banner() {
    clear
    echo -e "${RED}${WHITE}"
    cat << "EOF"
██╗  ██╗███████╗██╗  ██╗███████╗████████╗██████╗ ██╗██╗  ██╗███████╗
██║  ██║██╔════╝╚██╗██╔╝██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝██╔════╝
███████║█████╗   ╚███╔╝ ███████╗   ██║   ██████╔╝██║█████╔╝ █████╗  
██╔══██║██╔══╝   ██╔██╗ ╚════██║   ██║   ██╔══██╗██║██╔═██╗ ██╔══╝  
██║  ██║███████╗██╔╝ ██╗███████║   ██║   ██║  ██║██║██║  ██╗███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│  ${WHITE}🚀 HexStrike AI v6.0 - Linux Setup Script                      ${CYAN}│${NC}"
    echo -e "${CYAN}│  ${YELLOW}⚡ AI-Automated Recon | Exploitation | Analysis Pipeline      ${CYAN}│${NC}"
    echo -e "${CYAN}│  ${PURPLE}🎯 Bug Bounty | CTF | Red Team | Zero-Day Research            ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────┘${NC}"
    echo -e ""
}

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Status functions
status_ok() {
    echo -e "${GREEN}[✓]${NC} $1"
    log "INFO" "$1"
}

status_error() {
    echo -e "${RED}[✗]${NC} $1"
    log "ERROR" "$1"
}

status_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    log "WARNING" "$1"
}

status_info() {
    echo -e "${BLUE}[i]${NC} $1"
    log "INFO" "$1"
}

# Error handler
error_exit() {
    status_error "$1"
    echo -e "${RED}Setup failed. Check ${LOG_FILE} for details.${NC}"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        status_warning "Running as root. This is not recommended for security reasons."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
    elif command -v lsb_release >/dev/null; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        DISTRO_VERSION=$(lsb_release -sr)
    else
        status_warning "Cannot detect Linux distribution. Assuming Ubuntu/Debian."
        DISTRO="ubuntu"
    fi
    
    status_info "Detected distribution: ${DISTRO} ${DISTRO_VERSION}"
}

# Check Python version
check_python() {
    status_info "Checking Python installation..."
    
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        status_ok "Python ${PYTHON_VERSION} found"
        
        # Version comparison (simplified)
        if python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"; then
            status_ok "Python version is compatible (>= ${PYTHON_MIN_VERSION})"
        else
            error_exit "Python ${PYTHON_MIN_VERSION}+ required. Found: ${PYTHON_VERSION}"
        fi
    else
        error_exit "Python3 not found. Please install Python 3.8+."
    fi
}

# Install system dependencies
install_system_deps() {
    status_info "Installing system dependencies..."
    
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get update -qq
            sudo apt-get install -y \
                python3-pip \
                python3-venv \
                python3-dev \
                build-essential \
                cmake \
                git \
                curl \
                wget \
                unzip \
                chromium-browser \
                chromium-chromedriver \
                nmap \
                masscan \
                gobuster \
                ffuf \
                nikto \
                sqlmap \
                john \
                hashcat \
                hydra \
                dirb \
                dirsearch \
                amass \
                subfinder \
                nuclei \
                httpx \
                katana \
                gdb \
                radare2 \
                binwalk \
                foremost \
                steghide \
                exiftool \
                wireshark-common \
                tshark \
                tcpdump \
                aircrack-ng \
                recon-ng \
                theharvester \
                maltego \
                zaproxy \
                burpsuite \
                metasploit-framework 2>/dev/null || true
            ;;
        fedora|centos|rhel)
            sudo dnf update -q
            sudo dnf install -y \
                python3-pip \
                python3-devel \
                python3-venv \
                gcc \
                gcc-c++ \
                make \
                cmake \
                git \
                curl \
                wget \
                unzip \
                chromium \
                chromedriver \
                nmap \
                masscan \
                gobuster \
                ffuf \
                nikto \
                sqlmap \
                john \
                hashcat \
                hydra \
                dirb \
                gdb \
                radare2 \
                binwalk \
                foremost \
                steghide \
                exiftool \
                wireshark \
                tcpdump \
                aircrack-ng 2>/dev/null || true
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                python-pip \
                python-virtualenv \
                base-devel \
                cmake \
                git \
                curl \
                wget \
                unzip \
                chromium \
                chromedriver \
                nmap \
                masscan \
                gobuster \
                ffuf \
                nikto \
                sqlmap \
                john \
                hashcat \
                hydra \
                dirb \
                gdb \
                radare2 \
                binwalk \
                foremost \
                steghide \
                exiftool \
                wireshark-cli \
                tcpdump \
                aircrack-ng 2>/dev/null || true
            ;;
        *)
            status_warning "Unsupported distribution: ${DISTRO}"
            status_info "Please install the following manually:"
            echo "  - python3-pip python3-venv python3-dev build-essential cmake"
            echo "  - chromium-browser chromedriver"
            echo "  - nmap masscan gobuster ffuf nikto sqlmap john hashcat hydra"
            echo "  - gdb radare2 binwalk wireshark tcpdump"
            read -p "Press Enter to continue or Ctrl+C to exit..."
            ;;
    esac
    
    status_ok "System dependencies installation completed"
}

# Install Go-based tools
install_go_tools() {
    status_info "Installing Go-based security tools..."
    
    # Check if Go is installed
    if ! command -v go >/dev/null 2>&1; then
        status_info "Installing Go..."
        case $DISTRO in
            ubuntu|debian)
                sudo apt-get install -y golang-go
                ;;
            fedora|centos|rhel)
                sudo dnf install -y golang
                ;;
            arch|manjaro)
                sudo pacman -S --noconfirm go
                ;;
        esac
    fi
    
    # Install Go tools
    GO_TOOLS=(
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
        "github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
        "github.com/projectdiscovery/httpx/cmd/httpx@latest"
        "github.com/projectdiscovery/katana/cmd/katana@latest"
        "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
        "github.com/OWASP/Amass/v3/...@latest"
        "github.com/ffuf/ffuf@latest"
        "github.com/tomnomnom/gau@latest"
        "github.com/tomnomnom/waybackurls@latest"
        "github.com/tomnomnom/anew@latest"
        "github.com/tomnomnom/qsreplace@latest"
        "github.com/s0md3v/uro@latest"
    )
    
    for tool in "${GO_TOOLS[@]}"; do
        status_info "Installing ${tool}..."
        go install "${tool}" 2>/dev/null || status_warning "Failed to install ${tool}"
    done
    
    # Add Go bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
        echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc
        export PATH=$PATH:$HOME/go/bin
    fi
    
    status_ok "Go-based tools installation completed"
}

# Create virtual environment
create_venv() {
    status_info "Creating Python virtual environment..."
    
    if [[ -d "$VENV_DIR" ]]; then
        status_warning "Virtual environment already exists. Removing..."
        rm -rf "$VENV_DIR"
    fi
    
    python3 -m venv "$VENV_DIR" || error_exit "Failed to create virtual environment"
    source "$VENV_DIR/bin/activate" || error_exit "Failed to activate virtual environment"
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel
    
    status_ok "Virtual environment created and activated"
}

# Install Python dependencies
install_python_deps() {
    status_info "Installing Python dependencies..."
    
    # Ensure venv is activated
    source "$VENV_DIR/bin/activate" || error_exit "Failed to activate virtual environment"
    
    # Install core dependencies first
    pip install \
        flask \
        requests \
        psutil \
        fastmcp \
        beautifulsoup4 \
        selenium \
        webdriver-manager \
        aiohttp \
        mitmproxy || error_exit "Failed to install core dependencies"
    
    # Try to install binary analysis tools (optional)
    status_info "Installing binary analysis tools (may take a few minutes)..."
    pip install pwntools angr || status_warning "Some binary analysis tools failed to install (optional)"
    
    status_ok "Python dependencies installation completed"
}

# Configure Chrome/Chromium
configure_chrome() {
    status_info "Configuring Chrome/Chromium for browser automation..."
    
    # Check for Chrome/Chromium
    if command -v google-chrome >/dev/null 2>&1; then
        CHROME_PATH=$(which google-chrome)
        status_ok "Google Chrome found: ${CHROME_PATH}"
    elif command -v chromium-browser >/dev/null 2>&1; then
        CHROME_PATH=$(which chromium-browser)
        status_ok "Chromium found: ${CHROME_PATH}"
    elif command -v chromium >/dev/null 2>&1; then
        CHROME_PATH=$(which chromium)
        status_ok "Chromium found: ${CHROME_PATH}"
    else
        status_warning "Chrome/Chromium not found. Browser agent may not work."
        return
    fi
    
    # Check for ChromeDriver
    if command -v chromedriver >/dev/null 2>&1; then
        CHROMEDRIVER_PATH=$(which chromedriver)
        status_ok "ChromeDriver found: ${CHROMEDRIVER_PATH}"
    else
        status_warning "ChromeDriver not found. Installing via webdriver-manager..."
        source "$VENV_DIR/bin/activate"
        python3 -c "from webdriver_manager.chrome import ChromeDriverManager; ChromeDriverManager().install()" || status_warning "ChromeDriver auto-install failed"
    fi
}

# Setup MCP integration
setup_mcp_integration() {
    status_info "Setting up MCP integration configurations..."
    
    # Claude Desktop configuration
    CLAUDE_CONFIG_DIR="$HOME/.config/Claude"
    mkdir -p "$CLAUDE_CONFIG_DIR"
    
    cat > "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "hexstrike-ai": {
      "command": "python3",
      "args": [
        "$HEXSTRIKE_DIR/hexstrike_mcp.py",
        "--server",
        "http://localhost:$DEFAULT_PORT"
      ],
      "description": "HexStrike AI v6.0 - Advanced Cybersecurity Automation Platform",
      "timeout": 300,
      "disabled": false
    }
  }
}
EOF
    
    # VS Code/Cursor configuration
    mkdir -p "$HEXSTRIKE_DIR/.vscode"
    cat > "$HEXSTRIKE_DIR/.vscode/settings.json" << EOF
{
  "mcp": {
    "servers": {
      "hexstrike": {
        "type": "stdio",
        "command": "python3",
        "args": [
          "$HEXSTRIKE_DIR/hexstrike_mcp.py",
          "--server",
          "http://localhost:$DEFAULT_PORT"
        ],
        "description": "HexStrike AI v6.0 - Advanced Cybersecurity Automation Platform"
      }
    }
  }
}
EOF
    
    status_ok "MCP integration configurations created"
}

# Create startup script
create_startup_script() {
    status_info "Creating startup script..."
    
    cat > "$HEXSTRIKE_DIR/start_hexstrike.sh" << EOF
#!/bin/bash
# HexStrike AI Startup Script

HEXSTRIKE_DIR="$HEXSTRIKE_DIR"
VENV_DIR="$VENV_DIR"
PORT=${DEFAULT_PORT}

cd "\$HEXSTRIKE_DIR"

# Activate virtual environment
source "\$VENV_DIR/bin/activate"

# Start server
echo "Starting HexStrike AI server on port \$PORT..."
python3 hexstrike_server.py --port \$PORT

EOF
    
    chmod +x "$HEXSTRIKE_DIR/start_hexstrike.sh"
    
    # Create systemd service (optional)
    cat > "$HEXSTRIKE_DIR/hexstrike.service" << EOF
[Unit]
Description=HexStrike AI Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HEXSTRIKE_DIR
Environment=PATH=$VENV_DIR/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$VENV_DIR/bin/python hexstrike_server.py --port $DEFAULT_PORT
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
    
    status_ok "Startup scripts created"
}

# Test installation
test_installation() {
    status_info "Testing installation..."
    
    # Activate venv
    source "$VENV_DIR/bin/activate" || error_exit "Failed to activate virtual environment"
    
    # Test Python imports
    python3 -c "import flask, requests, psutil, fastmcp, beautifulsoup4, selenium, aiohttp" || error_exit "Core Python dependencies test failed"
    
    # Test optional imports
    python3 -c "import pwntools, angr" 2>/dev/null && status_ok "Binary analysis tools available" || status_warning "Binary analysis tools not available"
    
    # Start server in test mode (background)
    status_info "Starting server for health check..."
    python3 hexstrike_server.py --port $DEFAULT_PORT &
    SERVER_PID=$!
    
    # Wait for server to start
    sleep 5
    
    # Test health endpoint
    if curl -s "http://localhost:$DEFAULT_PORT/health" >/dev/null; then
        status_ok "Server health check passed"
        
        # Test AI analysis endpoint
        if curl -s -X POST "http://localhost:$DEFAULT_PORT/api/intelligence/analyze-target" \
           -H "Content-Type: application/json" \
           -d '{"target": "example.com", "analysis_type": "comprehensive"}' >/dev/null; then
            status_ok "AI analysis endpoint test passed"
        else
            status_warning "AI analysis endpoint test failed"
        fi
    else
        status_warning "Server health check failed"
    fi
    
    # Stop test server
    kill $SERVER_PID 2>/dev/null || true
    sleep 2
    
    status_ok "Installation test completed"
}

# Create documentation
create_docs() {
    status_info "Creating documentation..."
    
    cat > "$HEXSTRIKE_DIR/LINUX_SETUP_COMPLETE.md" << EOF
# HexStrike AI v6.0 - Linux Setup Complete

## Installation Summary
- **Installation Date**: $(date)
- **Linux Distribution**: $DISTRO $DISTRO_VERSION
- **Python Version**: $PYTHON_VERSION
- **Installation Directory**: $HEXSTRIKE_DIR
- **Virtual Environment**: $VENV_DIR
- **Default Port**: $DEFAULT_PORT

## Quick Start Commands

### Start Server
\`\`\`bash
cd $HEXSTRIKE_DIR
./start_hexstrike.sh
\`\`\`

### Manual Start
\`\`\`bash
cd $HEXSTRIKE_DIR
source $VENV_DIR/bin/activate
python3 hexstrike_server.py --port $DEFAULT_PORT
\`\`\`

### Health Check
\`\`\`bash
curl http://localhost:$DEFAULT_PORT/health
\`\`\`

### Example Usage
\`\`\`bash
# Target analysis
curl -X POST http://localhost:$DEFAULT_PORT/api/intelligence/analyze-target \\
  -H "Content-Type: application/json" \\
  -d '{"target": "example.com", "analysis_type": "comprehensive"}'

# Browser automation
curl -X POST http://localhost:$DEFAULT_PORT/api/tools/browser-agent \\
  -H "Content-Type: application/json" \\
  -d '{"action": "navigate", "url": "https://example.com", "headless": true}'
\`\`\`

## MCP Integration

### Claude Desktop
Configuration created at: \`$HOME/.config/Claude/claude_desktop_config.json\`

### VS Code/Cursor
Configuration created at: \`$HEXSTRIKE_DIR/.vscode/settings.json\`

## System Service (Optional)

To run as a system service:
\`\`\`bash
sudo cp $HEXSTRIKE_DIR/hexstrike.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable hexstrike
sudo systemctl start hexstrike
\`\`\`

## Logs
- Setup log: \`$LOG_FILE\`
- Server logs: \`$HEXSTRIKE_DIR/hexstrike.log\`

## Security Notes
- Only use on systems you own or have explicit permission to test
- Review firewall settings if accessing from remote hosts
- Consider running behind a reverse proxy for production use

## Support
For issues or questions:
- Check setup log: \`$LOG_FILE\`
- Review README.md for additional tools and configuration
- Ensure all security tools are properly licensed for your use case

---
*Setup completed on $(date)*
EOF
    
    status_ok "Documentation created"
}

# Cleanup function
cleanup() {
    status_info "Cleaning up temporary files..."
    # Add cleanup tasks here if needed
}

# Main installation function
main() {
    show_banner
    
    status_info "Starting HexStrike AI v6.0 setup for Linux..."
    log "INFO" "Setup started by user: $(whoami) on $(hostname)"
    
    # Pre-installation checks
    check_root
    detect_distro
    check_python
    
    # Installation steps
    install_system_deps
    install_go_tools
    create_venv
    install_python_deps
    configure_chrome
    setup_mcp_integration
    create_startup_script
    test_installation
    create_docs
    cleanup
    
    # Success message
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║  ${WHITE}🎉 HexStrike AI v6.0 Setup Complete!${GREEN}                        ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║  ${CYAN}Server Ready: ${WHITE}http://localhost:$DEFAULT_PORT${GREEN}                      ║${NC}"
    echo -e "${GREEN}║  ${CYAN}Start Command: ${WHITE}./start_hexstrike.sh${GREEN}                          ║${NC}"
    echo -e "${GREEN}║  ${CYAN}Documentation: ${WHITE}LINUX_SETUP_COMPLETE.md${GREEN}                    ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    status_ok "Setup completed successfully!"
    status_info "To start the server: ./start_hexstrike.sh"
    status_info "For detailed usage: cat LINUX_SETUP_COMPLETE.md"
    
    # Ask if user wants to start the server now
    echo ""
    read -p "Start HexStrike AI server now? (Y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        status_info "Server not started. Run './start_hexstrike.sh' when ready."
    else
        status_info "Starting HexStrike AI server..."
        exec ./start_hexstrike.sh
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
