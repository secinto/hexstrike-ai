#!/bin/bash

# HexStrike AI v6.0 - Server Management Script
# Provides start, stop, restart, and status functionality

set -e

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/hexstrike-env"
SERVER_SCRIPT="${SCRIPT_DIR}/hexstrike_server.py"
PID_FILE="${SCRIPT_DIR}/.hexstrike.pid"
LOG_FILE="${SCRIPT_DIR}/hexstrike_server.log"
DEFAULT_PORT=8888
HEALTH_ENDPOINT="http://localhost:${DEFAULT_PORT}/health"

# Banner
show_banner() {
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
    echo -e "${CYAN}│  ${WHITE}🚀 HexStrike AI v6.0 - Server Management                       ${CYAN}│${NC}"
    echo -e "${CYAN}│  ${YELLOW}⚡ Start | Stop | Restart | Status | Logs | Health             ${CYAN}│${NC}"
    echo -e "${CYAN}└─────────────────────────────────────────────────────────────────────┘${NC}"
    echo -e ""
}

# Status functions
status_ok() {
    echo -e "${GREEN}[✓]${NC} $1"
}

status_error() {
    echo -e "${RED}[✗]${NC} $1"
}

status_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

status_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Get server PID from process list
get_server_pid() {
    local pid=$(ps aux | grep "[h]exstrike_server.py" | awk '{print $2}' | head -1)
    echo "$pid"
}

# Check if server is running
is_server_running() {
    local pid=$(get_server_pid)
    if [[ -n "$pid" ]]; then
        return 0
    else
        return 1
    fi
}

# Check server health via HTTP
check_server_health() {
    if curl -s "$HEALTH_ENDPOINT" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Get server status information
get_server_status() {
    local pid=$(get_server_pid)
    if [[ -n "$pid" ]]; then
        echo "Running (PID: $pid)"
        
        # Get additional process info
        if ps -p "$pid" -o pid,ppid,etime,pcpu,pmem,command >/dev/null 2>&1; then
            echo ""
            echo -e "${CYAN}Process Information:${NC}"
            ps -p "$pid" -o pid,ppid,etime,pcpu,pmem,command | head -2
        fi
        
        # Check health endpoint
        echo ""
        if check_server_health; then
            status_ok "Health endpoint responding"
            
            # Get health data
            local health_data=$(curl -s "$HEALTH_ENDPOINT" 2>/dev/null)
            if [[ $? -eq 0 ]]; then
                echo ""
                echo -e "${CYAN}Server Statistics:${NC}"
                echo "$health_data" | python3 -m json.tool 2>/dev/null | grep -E "(status|uptime|total_tools_available|success_rate|cpu_percent|memory_percent)" | head -10
            fi
        else
            status_warning "Health endpoint not responding"
        fi
    else
        echo "Not running"
    fi
}

# Start the server
start_server() {
    status_info "Starting HexStrike AI server..."
    
    # Check if already running
    if is_server_running; then
        local pid=$(get_server_pid)
        status_warning "Server is already running (PID: $pid)"
        return 1
    fi
    
    # Check if virtual environment exists
    if [[ ! -d "$VENV_DIR" ]]; then
        status_error "Virtual environment not found at: $VENV_DIR"
        status_info "Run setup first: python3 -m venv hexstrike-env && source hexstrike-env/bin/activate && pip install -r requirements.txt"
        return 1
    fi
    
    # Check if server script exists
    if [[ ! -f "$SERVER_SCRIPT" ]]; then
        status_error "Server script not found at: $SERVER_SCRIPT"
        return 1
    fi
    
    # Change to script directory
    cd "$SCRIPT_DIR"
    
    # Start server in background
    source "$VENV_DIR/bin/activate"
    nohup python3 hexstrike_server.py --port "$DEFAULT_PORT" > "$LOG_FILE" 2>&1 &
    local pid=$!
    
    # Save PID
    echo "$pid" > "$PID_FILE"
    
    # Wait a moment and check if it started successfully
    sleep 3
    
    if is_server_running; then
        local actual_pid=$(get_server_pid)
        status_ok "Server started successfully (PID: $actual_pid)"
        status_info "Port: $DEFAULT_PORT"
        status_info "Logs: $LOG_FILE"
        status_info "Health: $HEALTH_ENDPOINT"
        
        # Wait a bit more and check health
        sleep 2
        if check_server_health; then
            status_ok "Server is healthy and responding"
        else
            status_warning "Server started but health check failed"
        fi
    else
        status_error "Failed to start server"
        if [[ -f "$LOG_FILE" ]]; then
            echo ""
            echo -e "${YELLOW}Last 10 lines of log:${NC}"
            tail -10 "$LOG_FILE"
        fi
        return 1
    fi
}

# Stop the server
stop_server() {
    status_info "Stopping HexStrike AI server..."
    
    local pid=$(get_server_pid)
    if [[ -z "$pid" ]]; then
        status_warning "Server is not running"
        return 1
    fi
    
    # Try graceful shutdown first
    status_info "Sending SIGTERM to PID $pid..."
    kill -TERM "$pid" 2>/dev/null || true
    
    # Wait for graceful shutdown
    local count=0
    while is_server_running && [[ $count -lt 10 ]]; do
        sleep 1
        ((count++))
    done
    
    # Check if it stopped
    if ! is_server_running; then
        status_ok "Server stopped gracefully"
    else
        # Force kill if still running
        status_warning "Forcing shutdown with SIGKILL..."
        kill -KILL "$pid" 2>/dev/null || true
        sleep 2
        
        if ! is_server_running; then
            status_ok "Server force stopped"
        else
            status_error "Failed to stop server"
            return 1
        fi
    fi
    
    # Clean up PID file
    rm -f "$PID_FILE"
}

# Restart the server
restart_server() {
    status_info "Restarting HexStrike AI server..."
    stop_server
    sleep 2
    start_server
}

# Show server logs
show_logs() {
    if [[ ! -f "$LOG_FILE" ]]; then
        status_warning "Log file not found: $LOG_FILE"
        return 1
    fi
    
    local lines="${1:-50}"
    echo -e "${CYAN}Last $lines lines of server logs:${NC}"
    echo -e "${CYAN}File: $LOG_FILE${NC}"
    echo ""
    tail -n "$lines" "$LOG_FILE"
}

# Follow server logs
follow_logs() {
    if [[ ! -f "$LOG_FILE" ]]; then
        status_warning "Log file not found: $LOG_FILE"
        status_info "Start the server first to create log file"
        return 1
    fi
    
    echo -e "${CYAN}Following server logs (Ctrl+C to exit):${NC}"
    echo -e "${CYAN}File: $LOG_FILE${NC}"
    echo ""
    tail -f "$LOG_FILE"
}

# Test server endpoints
test_server() {
    status_info "Testing HexStrike AI server endpoints..."
    
    if ! is_server_running; then
        status_error "Server is not running"
        return 1
    fi
    
    echo ""
    
    # Test health endpoint
    echo -e "${CYAN}Testing health endpoint...${NC}"
    if curl -s "$HEALTH_ENDPOINT" >/dev/null; then
        status_ok "Health endpoint: OK"
    else
        status_error "Health endpoint: FAILED"
    fi
    
    # Test AI analysis endpoint
    echo -e "${CYAN}Testing AI analysis endpoint...${NC}"
    local test_response=$(curl -s -X POST "http://localhost:$DEFAULT_PORT/api/intelligence/analyze-target" \
        -H "Content-Type: application/json" \
        -d '{"target": "example.com", "analysis_type": "comprehensive"}' 2>/dev/null)
    
    if [[ $? -eq 0 && $(echo "$test_response" | grep -c "success") -gt 0 ]]; then
        status_ok "AI analysis endpoint: OK"
    else
        status_error "AI analysis endpoint: FAILED"
    fi
    
    # Test browser agent endpoint
    echo -e "${CYAN}Testing browser agent status...${NC}"
    local browser_response=$(curl -s -X POST "http://localhost:$DEFAULT_PORT/api/tools/browser-agent" \
        -H "Content-Type: application/json" \
        -d '{"action": "status"}' 2>/dev/null)
    
    if [[ $? -eq 0 && $(echo "$browser_response" | grep -c "success") -gt 0 ]]; then
        status_ok "Browser agent endpoint: OK"
    else
        status_error "Browser agent endpoint: FAILED"
    fi
    
    echo ""
    status_info "Endpoint testing completed"
}

# Show usage information
show_usage() {
    echo -e "${WHITE}Usage: $0 {start|stop|restart|status|logs|follow|test|health}${NC}"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo -e "  ${GREEN}start${NC}     - Start the HexStrike AI server"
    echo -e "  ${RED}stop${NC}      - Stop the HexStrike AI server"
    echo -e "  ${YELLOW}restart${NC}   - Restart the HexStrike AI server"
    echo -e "  ${BLUE}status${NC}    - Show server status and information"
    echo -e "  ${PURPLE}logs${NC}      - Show recent server logs (default: 50 lines)"
    echo -e "  ${CYAN}follow${NC}    - Follow server logs in real-time"
    echo -e "  ${WHITE}test${NC}      - Test server endpoints"
    echo -e "  ${GREEN}health${NC}    - Show server health information"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo -e "  $0 start              # Start the server"
    echo -e "  $0 logs 100           # Show last 100 log lines"
    echo -e "  $0 status             # Check server status"
    echo -e "  $0 follow             # Watch logs in real-time"
}

# Show health information
show_health() {
    if ! is_server_running; then
        status_error "Server is not running"
        return 1
    fi
    
    if ! check_server_health; then
        status_error "Server is not responding to health checks"
        return 1
    fi
    
    echo -e "${CYAN}HexStrike AI Server Health Information:${NC}"
    echo ""
    
    local health_data=$(curl -s "$HEALTH_ENDPOINT")
    if [[ $? -eq 0 ]]; then
        echo "$health_data" | python3 -m json.tool 2>/dev/null || echo "$health_data"
    else
        status_error "Failed to retrieve health data"
    fi
}

# Main function
main() {
    # Change to script directory
    cd "$SCRIPT_DIR"
    
    case "${1:-}" in
        start)
            show_banner
            start_server
            ;;
        stop)
            show_banner
            stop_server
            ;;
        restart)
            show_banner
            restart_server
            ;;
        status)
            show_banner
            echo -e "${CYAN}HexStrike AI Server Status:${NC}"
            echo ""
            get_server_status
            ;;
        logs)
            show_logs "${2:-50}"
            ;;
        follow)
            follow_logs
            ;;
        test)
            show_banner
            test_server
            ;;
        health)
            show_health
            ;;
        *)
            show_banner
            show_usage
            exit 1
            ;;
    esac
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
