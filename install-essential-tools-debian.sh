#!/bin/bash

# HexStrike AI - Essential Security Tools Installation Script (Debian/Ubuntu)
# Version: 1.0 - Quick Install
# Description: Fast installation of the most essential 50+ security tools
# 
# Usage: sudo ./install-essential-tools-debian.sh
# 
# This script installs only the most critical and commonly used tools:
# - Essential penetration testing tools (15 tools)
# - Most popular web application security tools (15 tools)  
# - Core binary analysis tools (10 tools)
# - Key network reconnaissance tools (10 tools)
# - Top OSINT tools (5 tools)
# - Basic password tools (5 tools)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Log file
LOG_FILE="/tmp/hexstrike-essential-$(date +%Y%m%d_%H%M%S).log"

# Helper functions
print_banner() {
    echo -e "${RED}
██╗  ██╗███████╗██╗  ██╗███████╗████████╗██████╗ ██╗██╗  ██╗███████╗
██║  ██║██╔════╝╚██╗██╔╝██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝██╔════╝
███████║█████╗   ╚███╔╝ ███████╗   ██║   ██████╔╝██║█████╔╝ █████╗  
██╔══██║██╔══╝   ██╔██╗ ╚════██║   ║   ██╔══██╗██║██╔═██╗ ██╔══╝  
██║  ██║███████╗██╔╝ ██╗███████║   ██║   ██║  ██║██║██║  ██╗███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝${RESET}

${PURPLE}┌─────────────────────────────────────────────────────────────────────┐
│  ⚡ HexStrike AI - Essential Tools Quick Install (Debian/Ubuntu)  │
│  🚀 Installing 50+ Most Critical Cybersecurity Tools             │  
│  🎯 Fast Setup - Get Started in 10-15 minutes                    │
└─────────────────────────────────────────────────────────────────────┘${RESET}
"
}

print_status() {
    local type="$1"
    local message="$2"
    case "$type" in
        "info")    echo -e "${BLUE}ℹ️  $message${RESET}" ;;
        "success") echo -e "${GREEN}✅ $message${RESET}" ;;
        "warning") echo -e "${YELLOW}⚠️  $message${RESET}" ;;
        "error")   echo -e "${RED}❌ $message${RESET}" ;;
        "progress") echo -e "${PURPLE}🔄 $message${RESET}" ;;
    esac
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$type] $message" >> "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "This script must be run as root (use sudo)"
        echo -e "${YELLOW}Usage: sudo $0${RESET}"
        exit 1
    fi
}

install_package_quick() {
    local package="$1"
    local description="$2"
    
    if dpkg -l | grep -q "^ii  $package "; then
        echo -ne "${GREEN}✓${RESET} "
        return 0
    fi
    
    echo -ne "${PURPLE}⟳${RESET} "
    if apt-get install -y "$package" >> "$LOG_FILE" 2>&1; then
        echo -ne "\b${GREEN}✓${RESET} "
        return 0
    else
        echo -ne "\b${RED}✗${RESET} "
        return 1
    fi
}

install_go_tool_quick() {
    local package="$1"
    local binary_name="$2"
    
    if command -v "$binary_name" &> /dev/null; then
        echo -ne "${GREEN}✓${RESET} "
        return 0
    fi
    
    echo -ne "${PURPLE}⟳${RESET} "
    if go install "$package@latest" >> "$LOG_FILE" 2>&1; then
        # Move from GOPATH to system path
        if [[ -f "$HOME/go/bin/$binary_name" ]]; then
            cp "$HOME/go/bin/$binary_name" /usr/local/bin/ 2>/dev/null || true
            chmod +x "/usr/local/bin/$binary_name" 2>/dev/null || true
        fi
        echo -ne "\b${GREEN}✓${RESET} "
    else
        echo -ne "\b${RED}✗${RESET} "
    fi
}

install_pip_tool_quick() {
    local package="$1"
    local description="$2"
    
    echo -ne "${PURPLE}⟳${RESET} "
    if pip3 install "$package" >> "$LOG_FILE" 2>&1; then
        echo -ne "\b${GREEN}✓${RESET} "
    else
        echo -ne "\b${RED}✗${RESET} "
    fi
}

main() {
    print_banner
    check_root
    
    print_status "info" "Quick installation starting - Log: $LOG_FILE"
    print_status "info" "This will take approximately 10-15 minutes"
    
    # Update system
    print_status "progress" "Updating system packages..."
    apt-get update >> "$LOG_FILE" 2>&1
    apt-get upgrade -y >> "$LOG_FILE" 2>&1
    print_status "success" "System updated"
    
    # Install essential dependencies
    print_status "progress" "Installing core dependencies..."
    echo -e "${WHITE}Core Dependencies:${RESET}"
    
    local core_deps=(
        "curl:HTTP client"
        "wget:File downloader"  
        "git:Version control"
        "python3:Python interpreter"
        "python3-pip:Python package manager"
        "golang-go:Go language"
        "build-essential:Compilation tools"
        "default-jdk:Java development kit"
    )
    
    for pkg_info in "${core_deps[@]}"; do
        IFS=':' read -r pkg desc <<< "$pkg_info"
        echo -n "  $desc: "
        install_package_quick "$pkg" "$desc"
        echo " $pkg"
    done
    echo ""
    
    # Essential Security Tools  
    print_status "progress" "Installing essential security tools..."
    echo -e "${WHITE}Essential Security Tools:${RESET}"
    
    local essential_tools=(
        "nmap:Network scanner"
        "sqlmap:SQL injection tool"
        "hydra:Login brute forcer"
        "john:Password cracker"
        "hashcat:Hash cracker"
        "nikto:Web server scanner"
        "dirb:Directory scanner"
        "masscan:Fast port scanner"
    )
    
    for pkg_info in "${essential_tools[@]}"; do
        IFS=':' read -r pkg desc <<< "$pkg_info"
        echo -n "  $desc: "
        install_package_quick "$pkg" "$desc"
        echo " $pkg"
    done
    
    # Modern Go-based tools
    echo -n "  Directory enumeration: "
    install_go_tool_quick "github.com/OJ/gobuster/v3" "gobuster"
    echo " gobuster"
    
    echo -n "  Fast web fuzzer: "
    install_go_tool_quick "github.com/ffuf/ffuf/v2" "ffuf" 
    echo " ffuf"
    
    echo -n "  Vulnerability scanner: "
    install_go_tool_quick "github.com/projectdiscovery/nuclei/v3/cmd/nuclei" "nuclei"
    echo " nuclei"
    
    echo -n "  HTTP toolkit: "
    install_go_tool_quick "github.com/projectdiscovery/httpx/cmd/httpx" "httpx"
    echo " httpx"
    
    echo -n "  Subdomain discovery: "
    install_go_tool_quick "github.com/projectdiscovery/subfinder/v2/cmd/subfinder" "subfinder"
    echo " subfinder"
    
    echo ""
    
    # Web Application Security
    print_status "progress" "Installing web application security tools..."
    echo -e "${WHITE}Web Application Security:${RESET}"
    
    local web_tools=(
        "wfuzz:Web application fuzzer"
        "whatweb:Web technology identifier"
        "wafw00f:WAF fingerprinter"
        "commix:Command injection tool"
        "uniscan:Web vulnerability scanner"
    )
    
    for pkg_info in "${web_tools[@]}"; do
        IFS=':' read -r pkg desc <<< "$pkg_info"
        echo -n "  $desc: "
        install_package_quick "$pkg" "$desc"
        echo " $pkg"
    done
    
    # Python web tools
    echo -n "  Parameter discovery: "
    install_pip_tool_quick "arjun" "Parameter discovery"
    echo " arjun"
    
    echo -n "  URL filtering: "
    install_pip_tool_quick "uro" "URL filtering"
    echo " uro"
    
    echo ""
    
    # Network Tools
    print_status "progress" "Installing network tools..."
    echo -e "${WHITE}Network Reconnaissance:${RESET}"
    
    local network_tools=(
        "netcat-openbsd:Network utility"
        "tcpdump:Packet analyzer"
        "wireshark:Network analyzer"
        "tshark:Terminal Wireshark"
        "arp-scan:ARP scanner"
        "nbtscan:NetBIOS scanner"
        "enum4linux:SMB enumeration"
        "rpcclient:RPC client"
        "dnsutils:DNS utilities"
        "whois:Domain information"
    )
    
    for pkg_info in "${network_tools[@]}"; do
        IFS=':' read -r pkg desc <<< "$pkg_info"
        echo -n "  $desc: "
        install_package_quick "$pkg" "$desc"
        echo " $pkg"
    done
    
    echo ""
    
    # Binary Analysis & Reverse Engineering
    print_status "progress" "Installing binary analysis tools..."
    echo -e "${WHITE}Binary Analysis & Reverse Engineering:${RESET}"
    
    local binary_tools=(
        "gdb:GNU Debugger"
        "radare2:Reverse engineering"
        "binwalk:Firmware analysis"
        "strings:Extract strings"
        "objdump:Object disassembler"
        "readelf:ELF reader"
        "xxd:Hex dump"
        "file:File type identifier"
    )
    
    for pkg_info in "${binary_tools[@]}"; do
        IFS=':' read -r pkg desc <<< "$pkg_info"
        echo -n "  $desc: "
        install_package_quick "$pkg" "$desc" 
        echo " $pkg"
    done
    
    # Python binary tools
    echo -n "  CTF toolkit: "
    install_pip_tool_quick "pwntools" "CTF toolkit"
    echo " pwntools"
    
    echo -n "  ROP gadget finder: "
    install_pip_tool_quick "ropper" "ROP gadget finder" 
    echo " ropper"
    
    echo ""
    
    # OSINT Tools
    print_status "progress" "Installing OSINT tools..."
    echo -e "${WHITE}OSINT & Intelligence Gathering:${RESET}"
    
    echo -n "  Shodan CLI: "
    install_pip_tool_quick "shodan" "Shodan CLI"
    echo " shodan"
    
    echo -n "  Censys CLI: "
    install_pip_tool_quick "censys" "Censys CLI"
    echo " censys"
    
    echo -n "  TheHarvester: "
    install_pip_tool_quick "theHarvester" "Email/domain harvester"
    echo " theHarvester"
    
    echo -n "  Recon-ng: "
    install_pip_tool_quick "recon-ng" "Reconnaissance framework"
    echo " recon-ng"
    
    echo ""
    
    # Forensics & CTF
    print_status "progress" "Installing forensics tools..."
    echo -e "${WHITE}Forensics & CTF Tools:${RESET}"
    
    local forensics_tools=(
        "foremost:File carving"
        "exiftool:Metadata reader"
        "steghide:Steganography"
        "binwalk:Firmware analysis"
        "volatility:Memory forensics"
        "scalpel:File carving"
    )
    
    for pkg_info in "${forensics_tools[@]}"; do
        IFS=':' read -r pkg desc <<< "$pkg_info"
        echo -n "  $desc: "
        install_package_quick "$pkg" "$desc"
        echo " $pkg"
    done
    
    echo ""
    
    # Cloud & Container Tools
    print_status "progress" "Installing cloud security tools..."
    echo -e "${WHITE}Cloud & Container Security:${RESET}"
    
    local cloud_tools=(
        "docker.io:Container platform"
        "awscli:AWS CLI"
    )
    
    for pkg_info in "${cloud_tools[@]}"; do
        IFS=':' read -r pkg desc <<< "$pkg_info"
        echo -n "  $desc: "
        install_package_quick "$pkg" "$desc"
        echo " $pkg"
    done
    
    echo -n "  AWS security scanner: "
    install_pip_tool_quick "prowler" "AWS security scanner"
    echo " prowler"
    
    echo -n "  Multi-cloud auditing: "
    install_pip_tool_quick "scoutsuite" "Multi-cloud auditing"
    echo " scout-suite"
    
    echo ""
    
    # Download essential wordlists
    print_status "progress" "Setting up wordlists..."
    mkdir -p /usr/share/wordlists
    
    if [[ ! -d "/usr/share/wordlists/seclists" ]]; then
        echo -n "  Downloading SecLists: "
        if git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/seclists >> "$LOG_FILE" 2>&1; then
            echo -e "${GREEN}✓${RESET}"
        else
            echo -e "${RED}✗${RESET}"
        fi
    fi
    
    # Download rockyou wordlist
    if [[ ! -f "/usr/share/wordlists/rockyou.txt" ]]; then
        echo -n "  Downloading rockyou wordlist: "
        if wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O /usr/share/wordlists/rockyou.txt; then
            echo -e "${GREEN}✓${RESET}"
        else
            echo -e "${RED}✗${RESET}"
        fi
    fi
    
    # Cleanup
    print_status "progress" "Cleaning up..."
    apt-get autoremove -y >> "$LOG_FILE" 2>&1 || true
    apt-get autoclean >> "$LOG_FILE" 2>&1 || true
    
    # Verify installation
    print_status "info" "Verifying essential tools installation..."
    
    local verification_tools=(
        "nmap" "masscan" "gobuster" "ffuf" "nuclei" "sqlmap" 
        "hydra" "john" "hashcat" "radare2" "gdb" "nikto"
        "httpx" "subfinder" "binwalk" "exiftool"
    )
    
    local installed_count=0
    local total_count=${#verification_tools[@]}
    
    echo ""
    echo -e "${WHITE}Essential Tools Verification (Top 16):${RESET}"
    echo -e "${WHITE}┌─────────────┬──────────┐${RESET}"
    echo -e "${WHITE}│ Tool        │ Status   │${RESET}"
    echo -e "${WHITE}├─────────────┼──────────┤${RESET}"
    
    for tool in "${verification_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "${WHITE}│${RESET} $(printf '%-11s' "$tool") ${WHITE}│${GREEN} ✅ FOUND  ${WHITE}│${RESET}"
            ((installed_count++))
        else
            echo -e "${WHITE}│${RESET} $(printf '%-11s' "$tool") ${WHITE}│${RED} ❌ MISSING${WHITE}│${RESET}"
        fi
    done
    
    echo -e "${WHITE}└─────────────┴──────────┘${RESET}"
    
    local percentage=$((installed_count * 100 / total_count))
    echo ""
    
    # Final status
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_status "success" "Essential tools installation completed!"
    echo -e "${WHITE}📊 Installation Results:${RESET}"
    echo -e "${CYAN}   Essential Tools Found: $installed_count/$total_count (${percentage}%)${RESET}"
    
    if [[ $percentage -ge 80 ]]; then
        echo -e "${GREEN}   🎉 Excellent! HexStrike AI is ready to use${RESET}"
    elif [[ $percentage -ge 60 ]]; then
        echo -e "${YELLOW}   ⚡ Good coverage - Most features will work${RESET}"
    else
        echo -e "${RED}   ⚠️  Limited coverage - Consider running full installation${RESET}"
    fi
    
    echo ""
    echo -e "${WHITE}🚀 Next Steps:${RESET}"
    echo -e "${CYAN}   1. Start HexStrike AI server:${RESET} ${GREEN}./hexstrike-manager.sh start${RESET}"
    echo -e "${CYAN}   2. Check tool status:${RESET} ${GREEN}./hexstrike-manager.sh tools${RESET}"  
    echo -e "${CYAN}   3. Test functionality:${RESET} ${GREEN}./hexstrike-manager.sh test basic${RESET}"
    echo ""
    echo -e "${YELLOW}💡 For complete tool coverage, run:${RESET} ${GREEN}sudo ./install-tools-debian.sh${RESET}"
    echo -e "${YELLOW}📄 Installation log:${RESET} $LOG_FILE"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# Run main function
main "$@"
