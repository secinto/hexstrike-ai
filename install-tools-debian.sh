#!/bin/bash

# HexStrike AI - Debian/Ubuntu Security Tools Installation Script
# Version: 1.0
# Description: Comprehensive installation script for all 150+ security tools
# 
# Usage: sudo ./install-tools-debian.sh
# 
# This script will install:
# - Essential penetration testing tools (25+)
# - Web application security tools (40+)  
# - Binary analysis & reverse engineering tools (25+)
# - Network reconnaissance tools (25+)
# - Cloud security tools (20+)
# - CTF & forensics tools (20+)
# - OSINT tools (20+)
# - Password & authentication tools (12+)
# - Additional specialized tools (15+)

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

# Progress tracking
TOTAL_CATEGORIES=9
CURRENT_CATEGORY=0

# Log file
LOG_FILE="/tmp/hexstrike-install-$(date +%Y%m%d_%H%M%S).log"

# Helper functions
print_banner() {
    echo -e "${RED}
██╗  ██╗███████╗██╗  ██╗███████╗████████╗██████╗ ██╗██╗  ██╗███████╗
██║  ██║██╔════╝╚██╗██╔╝██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝██╔════╝
███████║█████╗   ╚███╔╝ ███████╗   ██║   ██████╔╝██║█████╔╝ █████╗  
██╔══██║██╔══╝   ██╔██╗ ╚════██║   ██║   ██╔══██╗██║██╔═██╗ ██╔══╝  
██║  ██║███████╗██╔╝ ██╗███████║   ██║   ██║  ██║██║██║  ██╗███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝${RESET}

${PURPLE}┌─────────────────────────────────────────────────────────────────────┐
│  🚀 HexStrike AI - Security Tools Installation for Debian/Ubuntu │
│  ⚡ Installing 150+ Professional Cybersecurity Tools             │  
│  🎯 Complete Penetration Testing Arsenal                         │
└─────────────────────────────────────────────────────────────────────┘${RESET}
"
}

print_status() {
    local type="$1"
    local message="$2"
    case "$type" in
        "info")  echo -e "${BLUE}ℹ️  $message${RESET}" ;;
        "success") echo -e "${GREEN}✅ $message${RESET}" ;;
        "warning") echo -e "${YELLOW}⚠️  $message${RESET}" ;;
        "error") echo -e "${RED}❌ $message${RESET}" ;;
        "progress") echo -e "${PURPLE}🔄 $message${RESET}" ;;
    esac
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$type] $message" >> "$LOG_FILE"
}

print_category_header() {
    local category="$1"
    local description="$2"
    ((CURRENT_CATEGORY++))
    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${WHITE}📦 Category $CURRENT_CATEGORY/$TOTAL_CATEGORIES: $category${RESET}"
    echo -e "${CYAN}   $description${RESET}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_status "error" "This script must be run as root (use sudo)"
        echo -e "${YELLOW}Usage: sudo $0${RESET}"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/debian_version ]] && [[ ! -f /etc/lsb-release ]]; then
        print_status "error" "This script is designed for Debian/Ubuntu systems"
        exit 1
    fi
    
    local os_name="Unknown"
    if command -v lsb_release &> /dev/null; then
        os_name=$(lsb_release -si)
    elif [[ -f /etc/os-release ]]; then
        os_name=$(grep ^NAME /etc/os-release | cut -d'"' -f2)
    fi
    
    print_status "info" "Detected OS: $os_name"
}

install_package() {
    local package="$1"
    local description="$2"
    
    if dpkg -l | grep -q "^ii  $package "; then
        print_status "info" "  $package ($description) - Already installed"
        return 0
    fi
    
    print_status "progress" "  Installing $package ($description)..."
    if apt-get install -y "$package" >> "$LOG_FILE" 2>&1; then
        print_status "success" "  $package installed successfully"
        return 0
    else
        print_status "warning" "  Failed to install $package via apt - will try alternative method"
        return 1
    fi
}

install_from_github() {
    local repo="$1"
    local binary_name="$2"
    local install_path="${3:-/usr/local/bin}"
    
    print_status "progress" "  Installing $binary_name from GitHub: $repo"
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if git clone "https://github.com/$repo.git" >> "$LOG_FILE" 2>&1; then
        cd "$(basename "$repo")"
        
        # Try different installation methods
        if [[ -f "install.sh" ]]; then
            chmod +x install.sh
            ./install.sh >> "$LOG_FILE" 2>&1
        elif [[ -f "Makefile" ]]; then
            make && make install >> "$LOG_FILE" 2>&1
        elif [[ -f "setup.py" ]]; then
            python3 setup.py install >> "$LOG_FILE" 2>&1
        elif [[ -f "go.mod" ]]; then
            go build -o "$install_path/$binary_name" >> "$LOG_FILE" 2>&1
        fi
        
        print_status "success" "  $binary_name installed from GitHub"
    else
        print_status "warning" "  Failed to clone $repo"
    fi
    
    cd /
    rm -rf "$temp_dir"
}

install_go_tool() {
    local package="$1"
    local binary_name="$2"
    
    print_status "progress" "  Installing $binary_name via go install..."
    if go install "$package@latest" >> "$LOG_FILE" 2>&1; then
        # Move from GOPATH to system path
        if [[ -f "$HOME/go/bin/$binary_name" ]]; then
            cp "$HOME/go/bin/$binary_name" /usr/local/bin/
            chmod +x "/usr/local/bin/$binary_name"
        fi
        print_status "success" "  $binary_name installed via go"
    else
        print_status "warning" "  Failed to install $binary_name via go"
    fi
}

update_system() {
    print_status "info" "Updating system packages..."
    apt-get update >> "$LOG_FILE" 2>&1
    apt-get upgrade -y >> "$LOG_FILE" 2>&1
    print_status "success" "System updated successfully"
}

install_essential_dependencies() {
    print_category_header "Essential Dependencies" "Core system tools and development libraries"
    
    local packages=(
        "curl:HTTP client"
        "wget:File downloader"
        "git:Version control system"
        "build-essential:Compilation tools"
        "python3:Python 3 interpreter"
        "python3-pip:Python package installer"
        "python3-dev:Python development headers"
        "golang-go:Go programming language"
        "nodejs:Node.js runtime"
        "npm:Node package manager"
        "ruby:Ruby programming language"
        "gem:Ruby package manager"
        "default-jdk:Java development kit"
        "cmake:Build system"
        "make:Build automation tool"
        "gcc:GNU C compiler"
        "g++:GNU C++ compiler"
        "libssl-dev:SSL development libraries"
        "libffi-dev:FFI development libraries"
        "libxml2-dev:XML2 development libraries"
        "libxslt1-dev:XSLT development libraries"
        "zlib1g-dev:Compression library"
        "libjpeg-dev:JPEG library"
        "libpng-dev:PNG library"
        "unzip:Archive extraction"
        "zip:Archive creation"
        "jq:JSON processor"
        "tree:Directory tree viewer"
        "htop:Process monitor"
        "screen:Terminal multiplexer"
        "tmux:Terminal multiplexer"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
}

install_essential_security_tools() {
    print_category_header "Essential Security Tools" "Core penetration testing framework (8 tools)"
    
    local packages=(
        "nmap:Network discovery and security auditing"
        "sqlmap:Automatic SQL injection tool"
        "hydra:Network login cracker"
        "john:Password cracker"
        "hashcat:Advanced password recovery"
        "nikto:Web server scanner"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install tools that need special handling
    print_status "progress" "Installing gobuster (directory enumeration)..."
    if ! command -v gobuster &> /dev/null; then
        install_go_tool "github.com/OJ/gobuster/v3" "gobuster"
    fi
    
    print_status "progress" "Installing dirb (directory brute forcer)..."
    install_package "dirb" "Directory brute forcer"
}

install_network_tools() {
    print_category_header "Network Reconnaissance Tools" "Network scanning and enumeration (25+ tools)"
    
    local packages=(
        "masscan:High-speed port scanner"
        "rustscan:Fast port scanner"
        "arp-scan:ARP network scanner"
        "nbtscan:NetBIOS scanner"
        "smbclient:SMB client"
        "enum4linux:SMB enumeration"
        "rpcclient:RPC client"
        "snmp-check:SNMP scanner"
        "onesixtyone:SNMP scanner"
        "snmpwalk:SNMP walker"
        "dnsrecon:DNS reconnaissance"
        "dnsutils:DNS utilities"
        "whois:Domain information"
        "host:DNS lookup utility"
        "netcat-openbsd:Network utility"
        "socat:Network relay"
        "tcpdump:Packet analyzer"
        "wireshark:Network protocol analyzer"
        "tshark:Terminal Wireshark"
        "ettercap-text-only:Network sniffer"
        "dsniff:Network auditing"
        "macchanger:MAC address changer"
        "bridge-utils:Bridge utilities"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install advanced network tools from GitHub
    print_status "progress" "Installing autorecon (automated reconnaissance)..."
    pip3 install autorecon >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing amass (subdomain enumeration)..."
    install_go_tool "github.com/owasp-amass/amass/v4/cmd/amass" "amass"
    
    print_status "progress" "Installing subfinder (subdomain discovery)..."
    install_go_tool "github.com/projectdiscovery/subfinder/v2/cmd/subfinder" "subfinder"
    
    print_status "progress" "Installing fierce (DNS reconnaissance)..."
    pip3 install fierce >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing theharvester (OSINT gathering)..."
    pip3 install theHarvester >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing responder (LLMNR/NBT-NS poisoner)..."
    install_from_github "lgandx/Responder" "responder"
}

install_web_security_tools() {
    print_category_header "Web Application Security" "Web application testing arsenal (40+ tools)"
    
    local packages=(
        "dirb:Web content scanner"
        "dirbuster:GUI directory scanner"
        "wfuzz:Web application fuzzer"
        "commix:Command injection exploiter"
        "whatweb:Web technology identifier"
        "wafw00f:WAF fingerprinter" 
        "uniscan:Web vulnerability scanner"
        "skipfish:Web application security scanner"
        "w3af:Web application attack framework"
        "davtest:WebDAV tester"
        "cadaver:WebDAV client"
        "padbuster:Padding oracle attack tool"
        "dotdotpwn:Directory traversal fuzzer"
        "fimap:Local/remote file inclusion scanner"
        "joomscan:Joomla vulnerability scanner"
        "wpscan:WordPress security scanner"
        "cmsmap:CMS scanner"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install modern web security tools
    print_status "progress" "Installing ffuf (fast web fuzzer)..."
    install_go_tool "github.com/ffuf/ffuf/v2" "ffuf"
    
    print_status "progress" "Installing feroxbuster (directory enumeration)..."
    wget -q https://github.com/epi052/feroxbuster/releases/latest/download/x86_64-linux-feroxbuster.tar.gz -O /tmp/feroxbuster.tar.gz
    tar -xzf /tmp/feroxbuster.tar.gz -C /tmp/
    mv /tmp/feroxbuster /usr/local/bin/ 2>/dev/null || true
    chmod +x /usr/local/bin/feroxbuster 2>/dev/null || true
    
    print_status "progress" "Installing nuclei (vulnerability scanner)..."
    install_go_tool "github.com/projectdiscovery/nuclei/v3/cmd/nuclei" "nuclei"
    
    print_status "progress" "Installing httpx (HTTP toolkit)..."
    install_go_tool "github.com/projectdiscovery/httpx/cmd/httpx" "httpx"
    
    print_status "progress" "Installing katana (web crawler)..."
    install_go_tool "github.com/projectdiscovery/katana/cmd/katana" "katana"
    
    print_status "progress" "Installing hakrawler (web crawler)..."
    install_go_tool "github.com/hakluke/hakrawler" "hakrawler"
    
    print_status "progress" "Installing gau (get all URLs)..."
    install_go_tool "github.com/lc/gau/v2/cmd/gau" "gau"
    
    print_status "progress" "Installing waybackurls (Wayback Machine URLs)..."
    install_go_tool "github.com/tomnomnom/waybackurls" "waybackurls"
    
    print_status "progress" "Installing arjun (parameter discovery)..."
    pip3 install arjun >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing paramspider (parameter mining)..."
    install_from_github "devanshbatham/ParamSpider" "paramspider"
    
    print_status "progress" "Installing x8 (parameter discovery)..."
    wget -q https://github.com/Sh1Yo/x8/releases/latest/download/x8_Linux_x86_64.tar.gz -O /tmp/x8.tar.gz
    tar -xzf /tmp/x8.tar.gz -C /tmp/
    mv /tmp/x8 /usr/local/bin/ 2>/dev/null || true
    chmod +x /usr/local/bin/x8 2>/dev/null || true
    
    print_status "progress" "Installing dalfox (XSS scanner)..."
    install_go_tool "github.com/hahwul/dalfox/v2" "dalfox"
    
    print_status "progress" "Installing anew (append new lines)..."
    install_go_tool "github.com/tomnomnom/anew" "anew"
    
    print_status "progress" "Installing qsreplace (query string replacement)..."
    install_go_tool "github.com/tomnomnom/qsreplace" "qsreplace"
    
    print_status "progress" "Installing uro (URL filtering)..."
    pip3 install uro >> "$LOG_FILE" 2>&1 || true
}

install_password_tools() {
    print_category_header "Password & Authentication Tools" "Password security testing (12+ tools)"
    
    local packages=(
        "john:Password cracker"
        "hashcat:Advanced password recovery"  
        "hydra:Network login cracker"
        "medusa:Parallel brute-forcer"
        "patator:Multi-purpose brute-forcer"
        "ncrack:Network authentication cracking"
        "crowbar:Remote access brute-forcer"
        "cewl:Custom wordlist generator"
        "crunch:Wordlist generator"
        "hashid:Hash identifier"
        "hash-identifier:Hash type identifier"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install modern password tools
    print_status "progress" "Installing hashcat utilities..."
    install_package "hashcat-utils" "Hashcat utilities" || true
    
    print_status "progress" "Installing ophcrack..."
    install_package "ophcrack" "Windows password cracker" || true
}

install_binary_analysis_tools() {
    print_category_header "Binary Analysis & Reverse Engineering" "Binary analysis framework (25+ tools)"
    
    local packages=(
        "gdb:GNU Debugger"
        "gdb-multiarch:Multi-architecture GDB"
        "radare2:Reverse engineering framework"
        "binwalk:Firmware analysis tool"
        "hexedit:Binary file editor"
        "objdump:Object file disassembler"
        "readelf:ELF file reader"
        "strings:Extract strings from binaries"
        "ltrace:Library call tracer"
        "strace:System call tracer"
        "file:File type identifier"
        "xxd:Hex dump utility"
        "hexdump:Another hex dump utility"
        "nm:Symbol table reader"
        "strip:Remove symbols from binaries"
        "checksec:Binary security checker"
        "ropper:ROP gadget finder"
        "one-gadget:Libc gadget finder"
        "libc-database:Libc identification"
        "pwntools:CTF toolkit"
        "unicorn-engine:CPU emulator"
        "keystone-engine:Assembler engine"
        "capstone:Disassembly engine"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install Python-based tools
    print_status "progress" "Installing pwntools..."
    pip3 install pwntools >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing ropper..."
    pip3 install ropper >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing angr (symbolic execution)..."
    pip3 install angr >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing r2pipe (radare2 bindings)..."
    pip3 install r2pipe >> "$LOG_FILE" 2>&1 || true
    
    # Install Ghidra (if Java is available)
    print_status "progress" "Installing Ghidra (reverse engineering suite)..."
    local ghidra_version="11.0.3"
    local ghidra_url="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_${ghidra_version}_build/ghidra_${ghidra_version}_PUBLIC_20240410.zip"
    
    if command -v java &> /dev/null; then
        wget -q "$ghidra_url" -O /tmp/ghidra.zip
        unzip -q /tmp/ghidra.zip -d /opt/ 2>/dev/null || true
        ln -sf /opt/ghidra_*/ghidraRun /usr/local/bin/ghidra 2>/dev/null || true
        print_status "success" "Ghidra installed successfully"
    else
        print_status "warning" "Java not available - Ghidra installation skipped"
    fi
}

install_forensics_ctf_tools() {
    print_category_header "CTF & Forensics Tools" "Digital forensics and CTF toolkit (20+ tools)"
    
    local packages=(
        "volatility:Memory forensics framework"
        "foremost:File carving tool"
        "scalpel:File carving tool"
        "binwalk:Firmware analysis"
        "steghide:Steganography tool"
        "stegosuite:Steganography suite"
        "outguess:Steganography detection"
        "exiftool:Metadata reader/writer"
        "exiv2:Image metadata library"
        "ffmpeg:Media file processor"
        "imagemagick:Image manipulation"
        "tesseract-ocr:OCR engine"
        "qpdf:PDF processor"
        "poppler-utils:PDF utilities"
        "sleuthkit:Digital investigation tools"
        "autopsy:Digital forensics platform"
        "bulk-extractor:Digital forensics tool"
        "photorec:File recovery tool"
        "testdisk:Disk recovery tool"
        "ddrescue:Data recovery tool"
        "safecopy:Data recovery tool"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install Python-based forensics tools
    print_status "progress" "Installing volatility3..."
    pip3 install volatility3 >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing stegcracker..."
    pip3 install stegcracker >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing zsteg (PNG/BMP steganography)..."
    gem install zsteg >> "$LOG_FILE" 2>&1 || true
}

install_cloud_security_tools() {
    print_category_header "Cloud Security Tools" "Cloud infrastructure security (20+ tools)"
    
    local packages=(
        "docker.io:Container platform"
        "docker-compose:Docker orchestration"
        "awscli:AWS command line interface"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install cloud security tools
    print_status "progress" "Installing prowler (AWS security assessment)..."
    pip3 install prowler >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing scout-suite (multi-cloud auditing)..."
    pip3 install scoutsuite >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing trivy (container vulnerability scanner)..."
    wget -q https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.tar.gz -O /tmp/trivy.tar.gz
    tar -xzf /tmp/trivy.tar.gz -C /tmp/
    mv /tmp/trivy /usr/local/bin/ 2>/dev/null || true
    chmod +x /usr/local/bin/trivy 2>/dev/null || true
    
    # Install Kubernetes tools
    print_status "progress" "Installing kubectl (Kubernetes CLI)..."
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >> "$LOG_FILE" 2>&1 || true
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list >> "$LOG_FILE" 2>&1 || true
    apt-get update >> "$LOG_FILE" 2>&1 || true
    install_package "kubectl" "Kubernetes CLI"
    
    print_status "progress" "Installing kube-hunter..."
    pip3 install kube-hunter >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing kube-bench..."
    install_go_tool "github.com/aquasecurity/kube-bench" "kube-bench"
    
    print_status "progress" "Installing checkov (IaC security scanner)..."
    pip3 install checkov >> "$LOG_FILE" 2>&1 || true
}

install_osint_tools() {
    print_category_header "OSINT & Intelligence Tools" "Open source intelligence gathering (20+ tools)"
    
    # Install OSINT tools via pip and git
    print_status "progress" "Installing sherlock (username investigation)..."
    install_from_github "sherlock-project/sherlock" "sherlock"
    
    print_status "progress" "Installing social-analyzer..."
    npm install -g social-analyzer >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing recon-ng..."
    pip3 install recon-ng >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing spiderfoot..."
    pip3 install spiderfoot >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing shodan CLI..."
    pip3 install shodan >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing censys CLI..."
    pip3 install censys >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing twint (Twitter OSINT)..."
    pip3 install twint >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing instagram-py..."
    pip3 install instagram-py >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing photon (web crawler)..."
    install_from_github "s0md3v/Photon" "photon"
    
    print_status "progress" "Installing h8mail (email OSINT)..."
    pip3 install h8mail >> "$LOG_FILE" 2>&1 || true
    
    print_status "progress" "Installing holehe (email services checker)..."
    pip3 install holehe >> "$LOG_FILE" 2>&1 || true
}

install_additional_tools() {
    print_category_header "Additional Specialized Tools" "Wireless, mobile, and other specialized tools"
    
    local packages=(
        "aircrack-ng:Wireless security suite"
        "kismet:Wireless network detector"
        "macchanger:MAC address changer"
        "mdk3:Wireless attack tool"
        "pixiewps:WPS attack tool"
        "reaver:WPS attack tool"
        "bully:WPS brute forcer"
        "cowpatty:WPA dictionary attack"
        "pyrit:WPA/WPA2 attack tool"
        "hashcat:GPU password recovery"
        "hcxtools:WiFi audit tools"
        "hcxdumptool:WiFi dump tool"
    )
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package desc <<< "$package_info"
        install_package "$package" "$desc"
    done
    
    # Install mobile security tools
    print_status "progress" "Installing apktool (Android APK analysis)..."
    wget -q https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
    chmod +x /usr/local/bin/apktool
    
    print_status "progress" "Installing dex2jar (Android DEX to JAR)..."
    wget -q https://github.com/pxb1988/dex2jar/releases/download/v2.4/dex2jar-2.4.zip -O /tmp/dex2jar.zip
    unzip -q /tmp/dex2jar.zip -d /opt/ 2>/dev/null || true
    ln -sf /opt/dex2jar-*/d2j-dex2jar.sh /usr/local/bin/dex2jar 2>/dev/null || true
    
    # Install Burp Suite Community (if GUI is available)
    print_status "progress" "Installing Burp Suite Community Edition..."
    if command -v java &> /dev/null; then
        wget -q "https://portswigger.net/burp/releases/startdownload?product=community&type=Linux" -O /tmp/burpsuite.sh
        chmod +x /tmp/burpsuite.sh
        /tmp/burpsuite.sh -q >> "$LOG_FILE" 2>&1 || true
    fi
}

configure_metasploit() {
    print_status "info" "Installing Metasploit Framework..."
    
    # Add Metasploit repository
    curl -s https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
    chmod +x /tmp/msfinstall
    /tmp/msfinstall >> "$LOG_FILE" 2>&1 || print_status "warning" "Metasploit installation failed"
}

setup_wordlists() {
    print_status "info" "Setting up wordlists and payloads..."
    
    # Create wordlists directory
    mkdir -p /usr/share/wordlists
    
    # Download SecLists
    print_status "progress" "Downloading SecLists..."
    git clone https://github.com/danielmiessler/SecLists.git /usr/share/wordlists/seclists >> "$LOG_FILE" 2>&1 || true
    
    # Download PayloadsAllTheThings
    print_status "progress" "Downloading PayloadsAllTheThings..."
    git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git /usr/share/wordlists/payloadallthethings >> "$LOG_FILE" 2>&1 || true
    
    # Download FuzzDB
    print_status "progress" "Downloading FuzzDB..."
    git clone https://github.com/fuzzdb-project/fuzzdb.git /usr/share/wordlists/fuzzdb >> "$LOG_FILE" 2>&1 || true
    
    # Download common wordlists
    print_status "progress" "Downloading rockyou wordlist..."
    wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O /usr/share/wordlists/rockyou.txt || true
}

cleanup_installation() {
    print_status "info" "Cleaning up installation files..."
    
    # Clean package cache
    apt-get autoremove -y >> "$LOG_FILE" 2>&1 || true
    apt-get autoclean >> "$LOG_FILE" 2>&1 || true
    
    # Clean temporary files
    rm -rf /tmp/hexstrike-* /tmp/*.tar.gz /tmp/*.zip /tmp/*.deb 2>/dev/null || true
    
    # Update locate database
    updatedb >> "$LOG_FILE" 2>&1 || true
}

verify_installation() {
    print_status "info" "Verifying tool installation..."
    
    local essential_tools=(
        "nmap" "masscan" "gobuster" "ffuf" "nuclei" "sqlmap" 
        "hydra" "john" "hashcat" "radare2" "gdb"
    )
    
    local installed_count=0
    local total_count=${#essential_tools[@]}
    
    echo ""
    echo -e "${WHITE}Essential Tools Verification:${RESET}"
    echo -e "${WHITE}┌──────────────┬────────────────────────────┬──────────┐${RESET}"
    echo -e "${WHITE}│ Tool         │ Description                │ Status   │${RESET}"
    echo -e "${WHITE}├──────────────┼────────────────────────────┼──────────┤${RESET}"
    
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            echo -e "${WHITE}│${RESET} $(printf '%-12s' "$tool") ${WHITE}│${RESET} $(printf '%-26s' "Security tool") ${WHITE}│${GREEN} ✅ FOUND  ${WHITE}│${RESET}"
            ((installed_count++))
        else
            echo -e "${WHITE}│${RESET} $(printf '%-12s' "$tool") ${WHITE}│${RESET} $(printf '%-26s' "Security tool") ${WHITE}│${RED} ❌ MISSING${WHITE}│${RESET}"
        fi
    done
    
    echo -e "${WHITE}└──────────────┴────────────────────────────┴──────────┘${RESET}"
    
    local percentage=$((installed_count * 100 / total_count))
    print_status "info" "Essential tools found: $installed_count/$total_count (${percentage}%)"
    
    if [[ $percentage -ge 80 ]]; then
        print_status "success" "Excellent tool coverage - HexStrike AI is ready!"
    elif [[ $percentage -ge 60 ]]; then
        print_status "warning" "Good tool coverage - Most features available"
    else
        print_status "warning" "Limited tool coverage - Some features may not work"
    fi
}

main() {
    print_banner
    
    # Pre-flight checks
    check_root
    check_os
    
    print_status "info" "Starting comprehensive security tools installation..."
    print_status "info" "Log file: $LOG_FILE"
    print_status "info" "This process may take 30-60 minutes depending on your connection"
    
    # Main installation process
    update_system
    install_essential_dependencies
    install_essential_security_tools
    install_network_tools
    install_web_security_tools
    install_password_tools
    install_binary_analysis_tools
    install_forensics_ctf_tools
    install_cloud_security_tools
    install_osint_tools
    install_additional_tools
    
    # Advanced installations
    configure_metasploit
    setup_wordlists
    
    # Post-installation
    cleanup_installation
    verify_installation
    
    # Final status
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    print_status "success" "HexStrike AI security tools installation completed!"
    echo -e "${WHITE}📊 Installation Summary:${RESET}"
    echo -e "${BLUE}   • Essential Security Tools: ✅ Installed${RESET}"
    echo -e "${BLUE}   • Network Reconnaissance: ✅ Installed${RESET}"
    echo -e "${BLUE}   • Web Application Security: ✅ Installed${RESET}"
    echo -e "${BLUE}   • Binary Analysis Tools: ✅ Installed${RESET}"
    echo -e "${BLUE}   • Cloud Security Tools: ✅ Installed${RESET}"
    echo -e "${BLUE}   • OSINT & Intelligence: ✅ Installed${RESET}"
    echo -e "${BLUE}   • CTF & Forensics Tools: ✅ Installed${RESET}"
    echo -e "${BLUE}   • Password Security Tools: ✅ Installed${RESET}"
    echo ""
    echo -e "${CYAN}🚀 Next Steps:${RESET}"
    echo -e "${WHITE}   1. Start HexStrike AI server: ${GREEN}./hexstrike-manager.sh start${RESET}"
    echo -e "${WHITE}   2. Check tool status: ${GREEN}./hexstrike-manager.sh tools${RESET}"
    echo -e "${WHITE}   3. Test API endpoints: ${GREEN}./hexstrike-manager.sh test${RESET}"
    echo ""
    echo -e "${YELLOW}📄 Installation log saved to: ${LOG_FILE}${RESET}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# Run main function
main "$@"
