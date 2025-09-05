#!/bin/bash
# ============================================================================
# HexStrike AI - Setup and Server Management Script
# Version: 6.0
# Platform: macOS/Linux
# ============================================================================

set -e  # Exit on any error

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
VENV_NAME="hexstrike-env"
VENV_DIR="$PROJECT_DIR/$VENV_NAME"
DEFAULT_HOST="127.0.0.1"
DEFAULT_PORT="8888"
SERVER_SCRIPT="hexstrike_server.py"
MCP_SCRIPT="hexstrike_mcp.py"
LOG_DIR="$PROJECT_DIR/logs"
PID_FILE="$PROJECT_DIR/hexstrike.pid"
LOG_FILE="$LOG_DIR/hexstrike.log"

# Colors
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;208m'
BLUE='\033[38;5;51m'
PURPLE='\033[38;5;129m'
WHITE='\033[97m'
GRAY='\033[38;5;240m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_status() {
    local level="$1"
    local message="$2"
    case "$level" in
        "success") echo -e "${GREEN}✅ ${message}${RESET}" ;;
        "error") echo -e "${RED}❌ ${message}${RESET}" ;;
        "warning") echo -e "${YELLOW}⚠️  ${message}${RESET}" ;;
        "info") echo -e "${BLUE}ℹ️  ${message}${RESET}" ;;
        *) echo -e "${WHITE}${message}${RESET}" ;;
    esac
}

print_banner() {
    echo -e "${RED}${BOLD}"
    cat << 'EOF'
██╗  ██╗███████╗██╗  ██╗███████╗████████╗██████╗ ██╗██╗  ██╗███████╗
██║  ██║██╔════╝╚██╗██╔╝██╔════╝╚══██╔══╝██╔══██╗██║██║ ██╔╝██╔════╝
███████║█████╗   ╚███╔╝ ███████╗   ██║   ██████╔╝██║█████╔╝ █████╗  
██╔══██║██╔══╝   ██╔██╗ ╚════██║   ██║   ██╔══██╗██║██╔═██╗ ██╔══╝  
██║  ██║███████╗██╔╝ ██╗███████║   ██║   ██║  ██║██║██║  ██╗███████╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝
EOF
    echo -e "${RESET}"
    echo -e "${RED}┌─────────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${RED}│  ${WHITE}🚀 HexStrike AI - Cybersecurity Automation Platform v6.0${RED}        │${RESET}"
    echo -e "${RED}│  ${YELLOW}⚡ AI-Powered Security Testing & Bug Bounty Framework${RED}           │${RESET}"
    echo -e "${RED}│  ${PURPLE}🎯 150+ Security Tools | 12+ AI Agents${RED}                         │${RESET}"
    echo -e "${RED}└─────────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_process_running() {
    local pid="$1"
    [[ -n "$pid" ]] && ps -p "$pid" > /dev/null 2>&1
}

get_server_pid() {
    [[ -f "$PID_FILE" ]] && cat "$PID_FILE"
}

ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        print_status "success" "Created directory: $dir"
    fi
}

# ============================================================================
# SYSTEM REQUIREMENTS CHECK
# ============================================================================

check_requirements() {
    print_status "info" "Checking system requirements..."
    
    # Check OS
    local os_type=$(uname -s)
    case "$os_type" in
        Darwin) print_status "success" "Operating System: macOS" ;;
        Linux) print_status "success" "Operating System: Linux" ;;
        *) print_status "error" "Unsupported OS: $os_type" && return 1 ;;
    esac
    
    # Check Python 3
    if command_exists python3; then
        local python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        print_status "success" "Python 3 found: $python_version"
    else
        print_status "error" "Python 3 is required but not found"
        return 1
    fi
    
    # Check pip3
    if command_exists pip3; then
        print_status "success" "pip3 found"
    else
        print_status "error" "pip3 is required but not found"
        return 1
    fi
    
    # Optional tools
    command_exists git && print_status "success" "Git found" || print_status "warning" "Git not found"
    command_exists curl && print_status "success" "curl found" || print_status "warning" "curl not found"
    
    return 0
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

setup_environment() {
    print_status "info" "Setting up HexStrike AI environment..."
    
    # Create directories
    ensure_directory "$LOG_DIR"
    ensure_directory "$PROJECT_DIR/config"
    ensure_directory "$PROJECT_DIR/backups"
    
    # Create virtual environment
    if [[ ! -d "$VENV_DIR" ]]; then
        print_status "info" "Creating Python virtual environment..."
        python3 -m venv "$VENV_DIR"
        print_status "success" "Virtual environment created"
    else
        print_status "info" "Virtual environment already exists"
    fi
    
    # Install dependencies with progress
    print_status "info" "Installing Python dependencies..."
    source "$VENV_DIR/bin/activate"
    
    if [[ -f "$PROJECT_DIR/requirements.txt" ]]; then
        print_status "info" "Upgrading pip to latest version..."
        pip install --upgrade pip --quiet
        print_status "success" "pip upgraded"
        
        print_status "info" "Reading requirements.txt..."
        local total_deps=$(grep -v '^#' "$PROJECT_DIR/requirements.txt" | grep -v '^$' | wc -l | tr -d ' ')
        print_status "info" "Found $total_deps dependencies to install"
        
        # Install dependencies with progress
        print_status "info" "Installing dependencies (this may take a few minutes)..."
        echo -e "${GRAY}Progress: Installing core dependencies...${RESET}"
        
        # Show real-time progress
        local log_file="$LOG_DIR/pip_install.log"
        ensure_directory "$LOG_DIR"
        
        # Install with verbose output to log file and show progress
        {
            echo "=== pip install started at $(date) ==="
            pip install -r "$PROJECT_DIR/requirements.txt" --verbose 2>&1 | while read -r line; do
                echo "$line"
                # Show progress for major packages
                if echo "$line" | grep -q "Collecting"; then
                    local package=$(echo "$line" | sed 's/Collecting //' | cut -d' ' -f1)
                    echo -e "${BLUE}📦 Collecting: $package${RESET}" >&2
                elif echo "$line" | grep -q "Installing collected packages"; then
                    echo -e "${GREEN}🔧 Installing packages...${RESET}" >&2
                elif echo "$line" | grep -q "Successfully installed"; then
                    echo -e "${GREEN}✅ Installation completed!${RESET}" >&2
                fi
            done
            echo "=== pip install finished at $(date) ==="
        } > "$log_file" 2>&1 &
        
        local install_pid=$!
        local dots=0
        
        # Show progress animation while installing
        while kill -0 $install_pid 2>/dev/null; do
            local progress_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
            local char=${progress_chars[$((dots % ${#progress_chars[@]}))]}
            echo -ne "\r${BLUE}$char Installing dependencies... Please wait${RESET}"
            sleep 0.3
            ((dots++))
        done
        
        wait $install_pid
        local install_exit_code=$?
        
        echo -ne "\r${RESET}" # Clear progress line
        
        if [[ $install_exit_code -eq 0 ]]; then
            print_status "success" "All dependencies installed successfully"
            
            # Show installed packages summary
            local installed_count=$(pip list | wc -l | tr -d ' ')
            print_status "info" "Total packages in environment: $installed_count"
            
            # Check key dependencies
            local key_deps=("flask" "requests" "psutil" "fastmcp" "beautifulsoup4" "selenium")
            print_status "info" "Verifying key dependencies:"
            for dep in "${key_deps[@]}"; do
                if pip show "$dep" > /dev/null 2>&1; then
                    local version=$(pip show "$dep" | grep Version | cut -d' ' -f2)
                    echo -e "  ${GREEN}✅ $dep ($version)${RESET}"
                else
                    echo -e "  ${YELLOW}⚠️  $dep (not found)${RESET}"
                fi
            done
        else
            print_status "error" "Dependency installation failed"
            print_status "info" "Check the log file for details: $log_file"
            return 1
        fi
    else
        print_status "error" "requirements.txt not found"
        return 1
    fi
    
    # Create launchd plist for macOS
    if [[ "$(uname -s)" == "Darwin" ]]; then
        create_launchd_plist
    fi
    
    print_status "success" "Environment setup completed"
    configure_mcp_clients
}

create_launchd_plist() {
    local plist_file="$HOME/Library/LaunchAgents/com.hexstrike.ai.plist"
    ensure_directory "$(dirname "$plist_file")"
    
    cat > "$plist_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.hexstrike.ai</string>
    <key>ProgramArguments</key>
    <array>
        <string>$VENV_DIR/bin/python</string>
        <string>$PROJECT_DIR/$SERVER_SCRIPT</string>
    </array>
    <key>WorkingDirectory</key>
    <string>$PROJECT_DIR</string>
    <key>StandardOutPath</key>
    <string>$LOG_FILE</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/error.log</string>
    <key>KeepAlive</key>
    <false/>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
EOF
    print_status "success" "LaunchAgent plist created: $plist_file"
    print_status "info" "To enable auto-start: launchctl load $plist_file"
}

# ============================================================================
# SERVER MANAGEMENT
# ============================================================================

start_server() {
    print_status "info" "Starting HexStrike AI server..."
    
    # Check if already running
    local pid=$(get_server_pid)
    if is_process_running "$pid"; then
        print_status "warning" "Server already running (PID: $pid)"
        return 0
    fi
    
    # Check virtual environment
    if [[ ! -d "$VENV_DIR" ]]; then
        print_status "error" "Virtual environment not found. Run 'setup' first"
        return 1
    fi
    
    # Start server
    cd "$PROJECT_DIR"
    source "$VENV_DIR/bin/activate"
    nohup python3 "$SERVER_SCRIPT" \
        --port "${PORT:-$DEFAULT_PORT}" \
        >> "$LOG_FILE" 2>&1 &
    
    local server_pid=$!
    echo "$server_pid" > "$PID_FILE"
    
    # Check if started successfully
    sleep 2
    if is_process_running "$server_pid"; then
        print_status "success" "Server started (PID: $server_pid)"
        print_status "info" "URL: http://${HOST:-$DEFAULT_HOST}:${PORT:-$DEFAULT_PORT}"
        print_status "info" "Logs: $LOG_FILE"
    else
        print_status "error" "Failed to start server"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop_server() {
    print_status "info" "Stopping HexStrike AI server..."
    
    local pid=$(get_server_pid)
    if ! is_process_running "$pid"; then
        print_status "warning" "Server not running"
        rm -f "$PID_FILE"
        return 0
    fi
    
    # Graceful shutdown
    kill -TERM "$pid" 2>/dev/null || true
    
    # Wait for shutdown
    local count=0
    while is_process_running "$pid" && [[ $count -lt 10 ]]; do
        sleep 1
        ((count++))
    done
    
    # Force kill if needed
    if is_process_running "$pid"; then
        print_status "warning" "Force killing server..."
        kill -KILL "$pid" 2>/dev/null || true
    fi
    
    rm -f "$PID_FILE"
    print_status "success" "Server stopped"
}

restart_server() {
    stop_server
    sleep 2
    start_server
}

server_status() {
    local pid=$(get_server_pid)
    if is_process_running "$pid"; then
        print_status "success" "Server running (PID: $pid)"
        
        # Get process info
        if command_exists ps; then
            local info=$(ps -p "$pid" -o pid,pcpu,pmem,etime --no-headers 2>/dev/null || echo "N/A")
            print_status "info" "Process: $info"
        fi
        
        # Test health endpoint
        local url="http://${HOST:-$DEFAULT_HOST}:${PORT:-$DEFAULT_PORT}"
        if command_exists curl; then
            print_status "info" "Testing health endpoint..."
            local response=$(curl -s -m 5 "$url/health" 2>/dev/null || echo '{"status":"unreachable"}')
            echo "Health: $response"
        fi
    else
        print_status "error" "Server not running"
        rm -f "$PID_FILE"
        return 1
    fi
}

# ============================================================================
# CONFIGURATION MANAGEMENT
# ============================================================================

configure_mcp_clients() {
    print_status "info" "Configuring MCP clients..."
    
    local server_url="http://${HOST:-$DEFAULT_HOST}:${PORT:-$DEFAULT_PORT}"
    
    # Claude Desktop configuration
    local claude_config="$HOME/.config/Claude/claude_desktop_config.json"
    if ensure_directory "$(dirname "$claude_config")"; then
        cat > "$claude_config" << EOF
{
  "mcpServers": {
    "hexstrike-ai": {
      "command": "python3",
      "args": [
        "$PROJECT_DIR/$MCP_SCRIPT",
        "--server",
        "$server_url"
      ],
      "description": "HexStrike AI v6.0 - Advanced Cybersecurity Automation Platform",
      "timeout": 300,
      "disabled": false
    }
  }
}
EOF
        print_status "success" "Claude Desktop configuration created"
    fi
    
    # Cursor configuration
    local cursor_config="$PROJECT_DIR/.cursor/claude_desktop_config.json"
    if ensure_directory "$(dirname "$cursor_config")"; then
        cat > "$cursor_config" << EOF
{
  "mcpServers": {
    "hexstrike-ai": {
      "command": "python3",
      "args": [
        "$PROJECT_DIR/$MCP_SCRIPT",
        "--server",
        "$server_url"
      ],
      "description": "HexStrike AI v6.0 - Advanced Cybersecurity Automation Platform",
      "timeout": 300,
      "disabled": false
    }
  }
}
EOF
        print_status "success" "Cursor configuration created"
    fi
    
    # Update project MCP config
    cat > "$PROJECT_DIR/hexstrike-ai-mcp.json" << EOF
{
  "mcpServers": {
    "hexstrike-ai": {
      "command": "python3",
      "args": [
        "$PROJECT_DIR/$MCP_SCRIPT",
        "--server",
        "$server_url"
      ],
      "description": "HexStrike AI v6.0 - Advanced Cybersecurity Automation Platform. Turn off alwaysAllow if you dont want autonomous execution!",
      "timeout": 300,
      "alwaysAllow": []
    }
  }
}
EOF
    print_status "success" "Project MCP configuration updated"
}

# ============================================================================
# SECURITY TOOLS CHECK
# ============================================================================

check_security_tools() {
    print_status "info" "Checking security tools installation..."
    
    local tools=(
        "nmap:Network port scanner"
        "masscan:Fast port scanner" 
        "gobuster:Directory enumeration"
        "ffuf:Web fuzzer"
        "nuclei:Vulnerability scanner"
        "sqlmap:SQL injection tester"
        "hydra:Login cracker"
        "john:Password cracker"
        "hashcat:Hash cracker"
        "radare2:Reverse engineering"
        "gdb:GNU debugger"
        "docker:Container platform"
        "kubectl:Kubernetes CLI"
    )
    
    local found=0
    local total=${#tools[@]}
    
    echo ""
    echo -e "${RED}Security Tools Status:${RESET}"
    echo -e "${RED}┌──────────────┬────────────────────────────┬──────────┐${RESET}"
    echo -e "${RED}│ Tool         │ Description                │ Status   │${RESET}"
    echo -e "${RED}├──────────────┼────────────────────────────┼──────────┤${RESET}"
    
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r tool desc <<< "$tool_info"
        if command_exists "$tool"; then
            echo -e "${RED}│${RESET} $(printf '%-12s' "$tool") ${RED}│${RESET} $(printf '%-26s' "$desc") ${RED}│${GREEN} ✅ FOUND  ${RED}│${RESET}"
            ((found++))
        else
            echo -e "${RED}│${RESET} $(printf '%-12s' "$tool") ${RED}│${RESET} $(printf '%-26s' "$desc") ${RED}│${RED} ❌ MISSING${RED}│${RESET}"
        fi
    done
    
    echo -e "${RED}└──────────────┴────────────────────────────┴──────────┘${RESET}"
    
    local percentage=$((found * 100 / total))
    print_status "info" "Tools found: $found/$total (${percentage}%)"
    
    if [[ $percentage -ge 70 ]]; then
        print_status "success" "Good tool coverage"
    elif [[ $percentage -ge 40 ]]; then
        print_status "warning" "Basic tool coverage"
    else
        print_status "error" "Limited tool coverage"
    fi
    
    echo ""
    print_status "info" "Installation suggestions for macOS:"
    echo "  brew install nmap masscan gobuster ffuf nuclei sqlmap hydra john"
    echo "  brew install radare2 docker kubernetes-cli"
}

# ============================================================================
# LOG MANAGEMENT
# ============================================================================

view_logs() {
    local log_type="${1:-server}"
    
    case "$log_type" in
        server|main)
            if [[ -f "$LOG_FILE" ]]; then
                print_status "info" "Server logs (last 50 lines):"
                tail -n 50 "$LOG_FILE"
            else
                print_status "warning" "Log file not found: $LOG_FILE"
            fi
            ;;
        error)
            local error_log="$LOG_DIR/error.log"
            if [[ -f "$error_log" ]]; then
                print_status "info" "Error logs (last 50 lines):"
                tail -n 50 "$error_log"
            else
                print_status "warning" "Error log not found: $error_log"
            fi
            ;;
        *)
            print_status "error" "Invalid log type: $log_type"
            print_status "info" "Available: server, error"
            ;;
    esac
}

# ============================================================================
# MONITORING
# ============================================================================

monitor_server() {
    print_status "info" "Starting monitoring (Press Ctrl+C to exit)..."
    
    while true; do
        clear
        print_banner
        
        # Server status
        local pid=$(get_server_pid)
        if is_process_running "$pid"; then
            print_status "success" "Server Status: RUNNING (PID: $pid)"
            
            # System resources
            if command_exists ps; then
                local cpu_mem=$(ps -p "$pid" -o pcpu,pmem --no-headers 2>/dev/null || echo "N/A N/A")
                print_status "info" "CPU & Memory: $cpu_mem"
            fi
            
            # Test health endpoint
            local url="http://${HOST:-$DEFAULT_HOST}:${PORT:-$DEFAULT_PORT}"
            if command_exists curl; then
                local response=$(curl -o /dev/null -s -w "%{http_code}" -m 5 "$url/health" 2>/dev/null || echo "N/A")
                print_status "info" "Health Status: HTTP $response"
            fi
        else
            print_status "error" "Server Status: NOT RUNNING"
        fi
        
        # System load
        if command_exists uptime; then
            local load=$(uptime | awk -F'load average:' '{print $2}')
            print_status "info" "System Load:$load"
        fi
        
        # Recent logs
        if [[ -f "$LOG_FILE" ]]; then
            echo ""
            print_status "info" "Recent log entries:"
            tail -n 3 "$LOG_FILE" | while read -r line; do
                echo "  $line"
            done
        fi
        
        echo ""
        print_status "info" "Refreshing in 5 seconds..."
        sleep 5
    done
}

# ============================================================================
# BACKUP AND MAINTENANCE
# ============================================================================

backup_data() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$PROJECT_DIR/backups/hexstrike_backup_$timestamp.tar.gz"
    
    print_status "info" "Creating backup..."
    ensure_directory "$PROJECT_DIR/backups"
    
    tar -czf "$backup_file" \
        --exclude="$VENV_NAME" \
        --exclude="*.pyc" \
        --exclude="__pycache__" \
        --exclude="logs" \
        -C "$PROJECT_DIR" \
        . 2>/dev/null
    
    if [[ -f "$backup_file" ]]; then
        local size=$(du -h "$backup_file" | cut -f1)
        print_status "success" "Backup created: $backup_file ($size)"
    else
        print_status "error" "Backup failed"
        return 1
    fi
}

update_dependencies() {
    print_status "info" "Updating dependencies..."
    
    if [[ ! -d "$VENV_DIR" ]]; then
        print_status "error" "Virtual environment not found. Run setup first."
        return 1
    fi
    
    source "$VENV_DIR/bin/activate"
    
    print_status "info" "Upgrading pip to latest version..."
    pip install --upgrade pip --quiet
    print_status "success" "pip upgraded"
    
    if [[ -f "$PROJECT_DIR/requirements.txt" ]]; then
        print_status "info" "Checking for outdated packages..."
        local outdated_count=$(pip list --outdated --format=freeze | wc -l | tr -d ' ')
        
        if [[ $outdated_count -gt 0 ]]; then
            print_status "info" "Found $outdated_count packages to update"
            
            # Show what will be updated
            print_status "info" "Outdated packages:"
            pip list --outdated --format=columns | while read -r line; do
                echo -e "  ${YELLOW}$line${RESET}"
            done
            
            print_status "info" "Updating dependencies (this may take a while)..."
            
            # Update with progress animation
            local log_file="$LOG_DIR/pip_update.log"
            ensure_directory "$LOG_DIR"
            
            pip install --upgrade -r "$PROJECT_DIR/requirements.txt" --verbose > "$log_file" 2>&1 &
            local update_pid=$!
            local dots=0
            
            while kill -0 $update_pid 2>/dev/null; do
                local progress_chars=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
                local char=${progress_chars[$((dots % ${#progress_chars[@]}))]}
                echo -ne "\r${BLUE}$char Updating packages... Please wait${RESET}"
                sleep 0.3
                ((dots++))
            done
            
            wait $update_pid
            local update_exit_code=$?
            echo -ne "\r${RESET}" # Clear progress line
            
            if [[ $update_exit_code -eq 0 ]]; then
                print_status "success" "Dependencies updated successfully"
                
                # Show final status
                local final_outdated=$(pip list --outdated --format=freeze | wc -l | tr -d ' ')
                if [[ $final_outdated -eq 0 ]]; then
                    print_status "success" "All packages are now up to date"
                else
                    print_status "warning" "$final_outdated packages still need updates"
                fi
            else
                print_status "error" "Dependency update failed"
                print_status "info" "Check the log file for details: $log_file"
                return 1
            fi
        else
            print_status "success" "All dependencies are already up to date"
        fi
    else
        print_status "error" "requirements.txt not found"
        return 1
    fi
}

cleanup() {
    print_status "info" "Cleaning up temporary files..."
    
    # Clean Python cache
    find "$PROJECT_DIR" -name "*.pyc" -type f -delete 2>/dev/null || true
    find "$PROJECT_DIR" -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # Clean old logs (keep last 5)
    find "$LOG_DIR" -name "*.log.*" -type f | sort | head -n -5 | xargs rm -f 2>/dev/null || true
    
    print_status "success" "Cleanup completed"
}

# ============================================================================
# API ENDPOINT TESTING
# ============================================================================

# Test individual endpoint with pretty output
test_endpoint() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local expected_status="$4"
    local description="$5"
    
    local url="http://${HOST:-$DEFAULT_HOST}:${PORT:-$DEFAULT_PORT}${endpoint}"
    
    if command_exists curl; then
        echo -e "${BLUE}Testing: ${description}${RESET}"
        echo -e "${GRAY}Endpoint: ${method} ${endpoint}${RESET}"
        
        local start_time=$(date +%s.%N)
        local response
        local http_code
        
        if [[ "$method" == "GET" ]]; then
            response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null)
        else
            response=$(curl -s -w "\n%{http_code}" -X "$method" \
                -H "Content-Type: application/json" \
                -d "$data" "$url" 2>/dev/null)
        fi
        
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0.0")
        
        # Extract HTTP code (last line) and response body
        http_code=$(echo "$response" | tail -n1)
        local response_body=$(echo "$response" | head -n -1)
        
        # Check if response is valid JSON
        local is_json=false
        if echo "$response_body" | python3 -m json.tool > /dev/null 2>&1; then
            is_json=true
            # Pretty print JSON if available
            if command_exists jq; then
                response_body=$(echo "$response_body" | jq . 2>/dev/null || echo "$response_body")
            fi
        fi
        
        # Determine test result
        local test_result="FAILED"
        local result_color="$RED"
        
        if [[ "$http_code" == "$expected_status" ]]; then
            test_result="PASSED"
            result_color="$GREEN"
        elif [[ "$http_code" == "200" || "$http_code" == "201" ]] && [[ "$expected_status" == "2xx" ]]; then
            test_result="PASSED"
            result_color="$GREEN"
        fi
        
        # Print results
        echo -e "${result_color}Status: $test_result (HTTP $http_code)${RESET}"
        echo -e "${GRAY}Response Time: ${duration}s${RESET}"
        
        if [[ "$is_json" == "true" ]] && [[ ${#response_body} -lt 500 ]]; then
            echo -e "${GRAY}Response:${RESET}"
            echo "$response_body" | sed 's/^/  /'
        elif [[ ${#response_body} -gt 0 ]]; then
            echo -e "${GRAY}Response: ${response_body:0:200}...${RESET}"
        fi
        
        echo ""
        return $([[ "$test_result" == "PASSED" ]] && echo 0 || echo 1)
    else
        print_status "error" "curl is required for endpoint testing"
        return 1
    fi
}

# Basic endpoint tests
test_basic_endpoints() {
    print_status "info" "Testing basic API endpoints..."
    
    local passed=0
    local total=0
    
    # Health check
    ((total++))
    test_endpoint "GET" "/health" "" "200" "Health check endpoint" && ((passed++))
    
    # Generic command endpoint
    ((total++))
    test_endpoint "POST" "/api/command" '{"command":"echo test"}' "200" "Generic command execution" && ((passed++))
    
    # Cache stats
    ((total++))
    test_endpoint "GET" "/api/cache/stats" "" "200" "Cache statistics" && ((passed++))
    
    # Telemetry
    ((total++))
    test_endpoint "GET" "/api/telemetry" "" "200" "System telemetry" && ((passed++))
    
    # File operations
    ((total++))
    test_endpoint "GET" "/api/files/list" "" "200" "List files" && ((passed++))
    
    print_status "info" "Basic tests completed: $passed/$total passed"
    return $([[ $passed -eq $total ]] && echo 0 || echo 1)
}

# Advanced endpoint tests
test_advanced_endpoints() {
    print_status "info" "Testing advanced API endpoints..."
    
    local passed=0
    local total=0
    
    # Process management
    ((total++))
    test_endpoint "GET" "/api/processes/list" "" "200" "List active processes" && ((passed++))
    
    ((total++))
    test_endpoint "GET" "/api/processes/dashboard" "" "200" "Process dashboard" && ((passed++))
    
    # File operations - create test file
    ((total++))
    test_endpoint "POST" "/api/files/create" '{"filename":"test_file.txt","content":"test content"}' "200" "Create test file" && ((passed++))
    
    # File operations - list files again to see the created file
    ((total++))
    test_endpoint "GET" "/api/files/list" "" "200" "List files (should show test file)" && ((passed++))
    
    # File operations - delete test file
    ((total++))
    test_endpoint "DELETE" "/api/files/delete" '{"filename":"test_file.txt"}' "200" "Delete test file" && ((passed++))
    
    # Payload generation
    ((total++))
    test_endpoint "POST" "/api/payloads/generate" '{"type":"buffer","size":100,"pattern":"A"}' "200" "Generate test payload" && ((passed++))
    
    # Cache clear
    ((total++))
    test_endpoint "POST" "/api/cache/clear" "" "200" "Clear cache" && ((passed++))
    
    # Visual endpoints
    ((total++))
    test_endpoint "POST" "/api/visual/tool-output" '{"tool":"nmap","output":"test output"}' "200" "Format tool output" && ((passed++))
    
    print_status "info" "Advanced tests completed: $passed/$total passed"
    return $([[ $passed -eq $total ]] && echo 0 || echo 1)
}

# Intelligence engine tests
test_intelligence_endpoints() {
    print_status "info" "Testing AI intelligence endpoints..."
    
    local passed=0
    local total=0
    
    # Target analysis
    ((total++))
    test_endpoint "POST" "/api/intelligence/analyze-target" '{"target":"example.com"}' "200" "Analyze target with AI" && ((passed++))
    
    # Tool selection
    ((total++))
    test_endpoint "POST" "/api/intelligence/select-tools" '{"target":"example.com","objective":"quick"}' "200" "Select optimal tools" && ((passed++))
    
    # Parameter optimization
    ((total++))
    test_endpoint "POST" "/api/intelligence/optimize-parameters" '{"target":"example.com","tool":"nmap"}' "200" "Optimize tool parameters" && ((passed++))
    
    # Attack chain creation
    ((total++))
    test_endpoint "POST" "/api/intelligence/create-attack-chain" '{"target":"example.com","objective":"comprehensive"}' "200" "Create attack chain" && ((passed++))
    
    print_status "info" "Intelligence tests completed: $passed/$total passed"
    return $([[ $passed -eq $total ]] && echo 0 || echo 1)
}

# Comprehensive endpoint testing
test_api_endpoints() {
    local test_type="${1:-all}"
    
    # Check if server is running
    local pid=$(get_server_pid)
    if ! is_process_running "$pid"; then
        print_status "error" "Server is not running. Start the server first."
        return 1
    fi
    
    print_status "info" "Starting API endpoint testing suite..."
    local server_url="http://${HOST:-$DEFAULT_HOST}:${PORT:-$DEFAULT_PORT}"
    print_status "info" "Testing server at: $server_url"
    echo ""
    
    local overall_passed=0
    local overall_total=0
    
    case "$test_type" in
        "basic")
            test_basic_endpoints && ((overall_passed++)) || true
            ((overall_total++))
            ;;
        "advanced")
            test_advanced_endpoints && ((overall_passed++)) || true
            ((overall_total++))
            ;;
        "intelligence")
            test_intelligence_endpoints && ((overall_passed++)) || true
            ((overall_total++))
            ;;
        "all"|*)
            test_basic_endpoints && ((overall_passed++)) || true
            ((overall_total++))
            echo ""
            
            test_advanced_endpoints && ((overall_passed++)) || true
            ((overall_total++))
            echo ""
            
            test_intelligence_endpoints && ((overall_passed++)) || true
            ((overall_total++))
            ;;
    esac
    
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    if [[ $overall_passed -eq $overall_total ]]; then
        print_status "success" "All test suites passed! ($overall_passed/$overall_total)"
        echo -e "${GREEN}🎉 HexStrike AI API is fully functional!${RESET}"
    else
        print_status "warning" "Some tests failed: $overall_passed/$overall_total suites passed"
        print_status "info" "Check the logs for more details on failed tests"
    fi
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    return $([[ $overall_passed -eq $overall_total ]] && echo 0 || echo 1)
}

# ============================================================================
# HELP
# ============================================================================

show_help() {
    print_banner
    echo -e "${WHITE}USAGE:${RESET}"
    echo -e "    ${BLUE}./hexstrike-manager.sh [command] [options]${RESET}"
    echo ""
    echo -e "${WHITE}COMMANDS:${RESET}"
    echo -e "    ${GREEN}setup${RESET}       - Initial setup and installation"
    echo -e "    ${GREEN}start${RESET}       - Start the HexStrike AI server"
    echo -e "    ${GREEN}stop${RESET}        - Stop the HexStrike AI server"
    echo -e "    ${GREEN}restart${RESET}     - Restart the HexStrike AI server"
    echo -e "    ${GREEN}status${RESET}      - Check server status and health"
    echo -e "    ${GREEN}logs${RESET}        - View logs [server|error]"
    echo -e "    ${GREEN}monitor${RESET}     - Real-time monitoring"
    echo -e "    ${GREEN}config${RESET}      - Configure MCP clients"
    echo -e "    ${GREEN}tools${RESET}       - Check security tools"
    echo -e "    ${GREEN}backup${RESET}      - Backup configuration"
    echo -e "    ${GREEN}update${RESET}      - Update dependencies"
    echo -e "    ${GREEN}cleanup${RESET}     - Clean temporary files"
    echo -e "    ${GREEN}test${RESET}        - Test API endpoints [all|basic|advanced|intelligence]"
    echo -e "    ${GREEN}help${RESET}        - Show this help"
    echo ""
    echo -e "${WHITE}ENVIRONMENT VARIABLES:${RESET}"
    echo -e "    ${BLUE}HOST${RESET}         - Server host (default: $DEFAULT_HOST)"
    echo -e "    ${BLUE}PORT${RESET}         - Server port (default: $DEFAULT_PORT)"
    echo ""
    echo -e "${WHITE}EXAMPLES:${RESET}"
    echo -e "    ${GRAY}# Setup and start${RESET}"
    echo -e "    ${BLUE}./hexstrike-manager.sh setup${RESET}"
    echo -e "    ${BLUE}./hexstrike-manager.sh start${RESET}"
    echo ""
    echo -e "    ${GRAY}# Custom port${RESET}"
    echo -e "    ${BLUE}PORT=9000 ./hexstrike-manager.sh start${RESET}"
    echo ""
    echo -e "    ${GRAY}# Monitor server${RESET}"
    echo -e "    ${BLUE}./hexstrike-manager.sh monitor${RESET}"
    echo ""
    echo -e "    ${GRAY}# Test API endpoints${RESET}"
    echo -e "    ${BLUE}./hexstrike-manager.sh test all${RESET}"
    echo -e "    ${BLUE}./hexstrike-manager.sh test basic${RESET}"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local command="${1:-help}"
    
    case "$command" in
        setup)
            print_banner
            check_requirements && setup_environment
            ;;
        start)
            start_server
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server
            ;;
        status)
            server_status
            ;;
        logs)
            view_logs "${2:-server}"
            ;;
        monitor)
            monitor_server
            ;;
        config)
            configure_mcp_clients
            ;;
        tools)
            check_security_tools
            ;;
        backup)
            backup_data
            ;;
        update)
            update_dependencies
            ;;
        cleanup)
            cleanup
            ;;
        test)
            test_api_endpoints "${2:-all}"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_status "error" "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Handle interrupts gracefully
trap 'echo -e "\n${YELLOW}⚠️  Operation cancelled${RESET}"; exit 130' INT

# Run main function
main "$@"
