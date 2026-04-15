#!/bin/bash

# ShadowStrike - Advanced Cybersecurity Framework
# Features: Real tool execution, Config system, Session management, SearchSploit integration, Loot Management

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Setup directories
CONFIG_DIR="$HOME/.shadowstrike"
SESSION_DIR="$CONFIG_DIR/sessions"
LOOT_DIR="$CONFIG_DIR/loot"
CONFIG_FILE="$CONFIG_DIR/config.conf"
HISTORY_FILE="$CONFIG_DIR/history.log"

# Tool installation map
declare -A TOOL_INSTALL_MAP=(
    ["nmap"]="apt-get install nmap"
    ["nikto"]="apt-get install nikto"
    ["netdiscover"]="apt-get install netdiscover"
    ["searchsploit"]="apt-get install exploitdb"
    ["msfvenom"]="apt-get install metasploit-framework"
    ["sqlmap"]="apt-get install sqlmap"
    ["gobuster"]="apt-get install gobuster"
    ["hashcat"]="apt-get install hashcat"
)

# Initialize ShadowStrike
init_shadowstrike() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        mkdir -p "$SESSION_DIR"
        mkdir -p "$LOOT_DIR"
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << 'CONF'
TARGET_IP=""
TARGET_PORT="80"
TARGET_HOST=""
CONF
    fi
    
    source "$CONFIG_FILE"
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    fi
}

save_config() {
    cat > "$CONFIG_FILE" << CONF
TARGET_IP="$TARGET_IP"
TARGET_PORT="$TARGET_PORT"
TARGET_HOST="$TARGET_HOST"
CONF
}

# Loot Management
add_loot() {
    local loot_type=$1
    local loot_value=$2
    local target=$3
    local source=$4
    
    local loot_file="$LOOT_DIR/${loot_type}_loot.txt"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] Target: $target | Source: $source | Value: $loot_value" >> "$loot_file"
    echo -e "${GREEN}[+] Loot saved: $loot_type${NC}"
    log_activity "Loot captured - Type: $loot_type | Target: $target"
}

view_loot() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Loot Inventory${NC}"
    echo ""
    
    if [ -z "$(ls -A $LOOT_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}[!] No loot found yet${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local count=1
    for loot_file in "$LOOT_DIR"/*_loot.txt; do
        if [ -f "$loot_file" ]; then
            local loot_type=$(basename "$loot_file" _loot.txt)
            local loot_count=$(wc -l < "$loot_file")
            echo -e "${GREEN}$count${NC} - ${MAGENTA}$loot_type${NC} (${YELLOW}$loot_count items${NC})"
            count=$((count+1))
        fi
    done
    
    echo ""
    read -p "Enter loot type number to view (or 0 to go back): " loot_choice
    
    if [ "$loot_choice" != "0" ] && [ -n "$loot_choice" ]; then
        local selected=$(ls "$LOOT_DIR"/*_loot.txt 2>/dev/null | sed -n "${loot_choice}p")
        if [ -f "$selected" ]; then
            clear
            local loot_type=$(basename "$selected" _loot.txt)
            echo -e "${CYAN}${BOLD}[🥷] $loot_type - Captured Loot${NC}"
            echo ""
            cat "$selected"
            echo ""
            read -p "Press Enter to continue..."
        fi
    fi
}

export_loot() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Export Loot${NC}"
    echo ""
    
    if [ -z "$(ls -A $LOOT_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}[!] No loot to export${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter export filename (without extension): " export_name
    
    if [ -z "$export_name" ]; then
        echo -e "${RED}[!] No filename provided${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local export_file="${export_name}_$(date +%Y%m%d_%H%M%S).txt"
    
    echo -e "${YELLOW}[🗡️] ShadowStrike Loot Export${NC}" > "$export_file"
    echo -e "Generated: $(date)" >> "$export_file"
    echo -e "Current Target: $TARGET_IP:$TARGET_PORT" >> "$export_file"
    echo -e "==========================================\n" >> "$export_file"
    
    for loot_file in "$LOOT_DIR"/*_loot.txt; do
        if [ -f "$loot_file" ]; then
            local loot_type=$(basename "$loot_file" _loot.txt)
            echo -e "\n[*] ${loot_type^^}" >> "$export_file"
            echo "==========================================\n" >> "$export_file"
            cat "$loot_file" >> "$export_file"
        fi
    done
    
    echo -e "${GREEN}[+] Loot exported to: $export_file${NC}"
    read -p "Press Enter to continue..."
}

clear_loot() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Clear Loot${NC}"
    echo ""
    
    if [ -z "$(ls -A $LOOT_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}[!] No loot to clear${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${RED}[!] WARNING: This will delete all loot!${NC}"
    read -p "Are you sure? (y/n): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$LOOT_DIR"/*_loot.txt
        echo -e "${GREEN}[+] All loot cleared${NC}"
    else
        echo -e "${YELLOW}[!] Cancelled${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

manually_add_loot() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Manually Add Loot${NC}"
    echo -e "${WHITE}Current Target: $TARGET_IP:$TARGET_PORT${NC}"
    echo ""
    
    echo -e "${MAGENTA}Loot Types:${NC}"
    echo "1 - Credentials"
    echo "2 - Hashes"
    echo "3 - API Keys"
    echo "4 - Tokens"
    echo "5 - Emails"
    echo "6 - Domains"
    echo "7 - Custom"
    
    read -p "Select loot type: " loot_type_choice
    
    local loot_type=""
    case $loot_type_choice in
        1) loot_type="credentials" ;;
        2) loot_type="hashes" ;;
        3) loot_type="api_keys" ;;
        4) loot_type="tokens" ;;
        5) loot_type="emails" ;;
        6) loot_type="domains" ;;
        7) read -p "Enter custom loot type: " loot_type ;;
        *) echo -e "${RED}[!] Invalid option${NC}"; return ;;
    esac
    
    read -p "Enter loot value: " loot_value
    
    echo -e "${YELLOW}Use current target $TARGET_IP:$TARGET_PORT? (y/n): " 
    read use_current
    
    local target
    if [[ "$use_current" =~ ^[Yy]$ ]]; then
        target="$TARGET_IP:$TARGET_PORT"
    else
        read -p "Enter custom target: " target
    fi
    
    read -p "Enter source/method (optional): " source
    
    if [ -z "$loot_value" ]; then
        echo -e "${RED}[!] Loot value is required${NC}"
        return
    fi
    
    add_loot "$loot_type" "$loot_value" "$target" "$source"
    read -p "Press Enter to continue..."
}

tool_installed() {
    command -v "$1" &> /dev/null
}

auto_install_tool() {
    local tool=$1
    
    echo ""
    echo -e "${RED}[!] $tool is not installed${NC}"
    read -p "$(echo -e ${CYAN})[?]$(echo -e ${NC}) Install $tool? (y/n): " install_choice
    
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[🗡️] Installing $tool...${NC}"
        sudo apt-get update -qq
        sudo apt-get install -y "$tool" 2>/dev/null
        
        if tool_installed "$tool"; then
            echo -e "${GREEN}[+] $tool installed successfully!${NC}"
            return 0
        else
            echo -e "${RED}[!] Installation failed${NC}"
            return 1
        fi
    fi
    return 1
}

check_and_install_tool() {
    local tool=$1
    
    if ! tool_installed "$tool"; then
        if ! auto_install_tool "$tool"; then
            return 1
        fi
    fi
    return 0
}

log_activity() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$HISTORY_FILE"
}

print_banner() {
    clear
    echo -e "${RED}"
    cat << 'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠶⠚⠋⠉⠉⠙⠛⠲⠦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣶⣾⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⢿⠙⣿⣻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠹⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⡟⠁⢹⠿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡾⠀⠀⠘⢷⣼⢷⣄⡀⠀⠀⢤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⠀⠀⠀⠈⢻⡉⢣⠙⡶⣶⢾⣿⣿⡷⠀⠀⠀⠀⠀⠀⢀⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡀⣸⠆⠀⠀⠙⢆⠳⣆⠹⣿⣿⣿⣥⣄⠀⠀⠀⠀⠀⢾⡀⣸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠋⠉⠀⠀⠀⠀⠘⡄⣀⡉⠻⣟⣿⡏⠙⠃⠀⠀⠀⠀⠀⠉⠻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⡇⢸⣶⣤⣀⠀⠀⠀⠹⠁⢳⡀⢈⣻⡇⠀⠀⠀⠀⢀⣠⣴⣾⠀⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡌⣿⡟⠻⢷⣶⢄⡀⠀⠨⢿⢻⣿⠙⠀⣀⣤⣾⠿⠛⣿⡽⣸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⢫⡇⢻⣿⣄⠀⠈⠙⠿⣷⣤⣼⣆⣠⣴⡿⠛⠉⠀⠀⣴⡿⠁⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢷⡀⠀⠀⠀⠀⠀⠀⠀⢀⣾⠁⣠⣷⣄⠙⢝⠳⠶⠶⠞⢋⡠⠛⠚⠣⣉⠛⠲⠶⠖⣛⠟⢁⣴⠇⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴
⢸⣷⡄⠀⠀⠀⠀⠀⠀⢸⡇⡔⢡⡏⠹⢿⣄⣉⠁⠒⠈⠁⠀⠀⠀⠀⠀⠉⠐⠒⢉⣡⣼⣯⡶⠛⠋⢉⣩⠿⠛⠒⠂⠀⠀⠀⠀⢀⣼⡏
⠀⢿⠙⢦⡀⠀⠀⠀⠀⠘⣿⡁⡿⠀⢠⠞⢷⠈⠱⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⠉⢠⠟⠁⠀⡄⣄⣸⣆⠀⠀⠀⠀⠀⠀⠀⣠⠞⣸⠁
⠀⠘⣧⠀⠙⢦⡀⠀⠀⠀⠈⠻⣿⣶⣞⠛⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⡿⠀⢰⣋⣉⠉⣠⡜⠀⠀⠀⠀⢀⣠⠞⠁⢠⠏⠀
⠀⠀⠘⣧⡀⠀⠙⠷⣄⡀⠀⠀⠹⣯⡏⠙⠛⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣷⡶⢾⣇⣨⠽⠋⠀⠀⠀⣀⡴⠋⠁⠀⣰⠏⠀⠀
⠀⠀⠀⠈⠳⣄⠓⢄⠈⠛⢦⣄⠀⠘⢿⣄⡀⢹⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⣀⣀⣸⡦⠄⠀⣀⡤⠞⠉⣀⠔⢁⡼⠃⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠳⣦⡁⠢⢄⠈⠙⠶⣤⣈⠙⠻⠶⣿⣦⡀⠀⠀⠀⠀⠀⣠⣾⣥⠶⠛⠉⠁⢀⣠⡴⠚⠉⢀⠔⢊⣠⠞⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠙⠳⢤⣙⠢⢄⠀⠉⠓⠦⣄⣀⠀⠙⠓⠒⠒⠒⠛⠁⠀⠀⢀⣠⡤⠞⠋⠁⡀⠄⣊⣥⠶⠋⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠲⢬⣁⠂⠤⣀⠉⠛⠶⢤⣀⡀⠀⣀⣤⠶⠚⠉⢁⡠⠔⣂⣥⠶⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣈⡙⠲⢦⣍⣒⣤⣤⠼⠟⠋⢉⣀⠤⢒⣊⡥⠶⠛⣉⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣠⠤⣤⣀⣀⣀⣀⣀⣀⣀⣀⣀⣠⡏⠉⠉⡷⠖⠚⠋⣉⡠⠤⠐⢂⣩⡴⠶⢟⣉⡉⠛⠒⢶⠇⠉⢹⣧⣀⣀⣀⣀⣀⣀⣀⣀⣀⡠⠤⢄
⡇⠀⠀⠀⠀⡏⢠⡇⡇⢰⡀⡄⢀⢷⠀⡆⢹⣂⣈⣩⡤⠶⠞⠋⠉⠉⠙⠓⠶⠤⣬⣉⣐⡺⠀⠂⣸⢱⠀⠀⡃⠈⠀⠃⠈⠀⠀⠀⠀⢸
⠙⠢⠶⠴⠦⠷⠤⠷⠛⠒⠓⠛⠛⢻⣦⣵⡼⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠧⢼⣤⡟⠛⠛⠛⠳⠿⠭⠽⠤⠴⠦⠄⠀⠚

         ⚔️  SHADOWSTRIKE - SILENT • SWIFT • DEADLY ⚔️  
         🗡️  Real Tools • Sessions • SearchSploit • Loot 🗡️
         
EOF
    echo -e "${NC}"
}

show_main_menu() {
    echo -e "${CYAN}${BOLD}[🥷] ShadowStrike Main Menu${NC}"
    echo -e "${WHITE}Current Target: ${BOLD}$TARGET_IP:$TARGET_PORT${NC} | Host: $TARGET_HOST${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - Reconnaissance & Scanning"
    echo -e "${GREEN}  2${NC} - Vulnerability Assessment"
    echo -e "${GREEN}  3${NC} - Exploitation Framework"
    echo -e "${GREEN}  5${NC} - 💰 Loot Management"
    echo -e "${GREEN}  9${NC} - Settings & Configuration"
    echo -e "${RED}  0${NC} - Exit & Vanish"
    echo ""
}

show_loot_menu() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Loot Management${NC}"
    echo -e "${WHITE}Current Target: ${BOLD}$TARGET_IP:$TARGET_PORT${NC}${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - View All Loot"
    echo -e "${GREEN}  2${NC} - Manually Add Loot"
    echo -e "${GREEN}  3${NC} - Export Loot"
    echo -e "${GREEN}  4${NC} - Clear All Loot"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

show_recon_menu() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Reconnaissance & Scanning${NC}"
    echo -e "${WHITE}Current Target: ${BOLD}$TARGET_IP:$TARGET_PORT${NC}${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - NMAP (Port Scanning)"
    echo -e "${GREEN}  2${NC} - Netdiscover (ARP Scanning)"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

show_vuln_menu() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Vulnerability Assessment${NC}"
    echo -e "${WHITE}Current Target: ${BOLD}$TARGET_IP:$TARGET_PORT${NC}${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - Nikto (Web Server Scanner)"
    echo -e "${GREEN}  2${NC} - SearchSploit (Exploit Database)"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

show_exploit_menu() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Exploitation Framework${NC}"
    echo -e "${WHITE}Current Target: ${BOLD}$TARGET_IP:$TARGET_PORT${NC}${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - MSFVenom Payload Generator"
    echo -e "${GREEN}  2${NC} - Reverse Shell Generator"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

show_settings_menu() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Settings & Configuration${NC}"
    echo -e "${WHITE}Current Target: ${BOLD}$TARGET_IP:$TARGET_PORT${NC}${NC}"
    echo ""
    echo -e "${GREEN}  1${NC} - Configure Target IP/Host/Port"
    echo -e "${GREEN}  2${NC} - Check Installed Tools"
    echo -e "${RED}  0${NC} - Back"
    echo ""
}

run_nmap() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] NMAP Port Scanner${NC}"
    echo -e "${WHITE}Default Target: ${BOLD}$TARGET_IP:$TARGET_PORT${NC}${NC}"
    echo ""
    
    if ! check_and_install_tool "nmap"; then
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Use current target? (y/n): " use_current
    
    local target
    if [[ "$use_current" =~ ^[Yy]$ ]]; then
        target="$TARGET_IP"
    else
        read -p "Enter target IP: " target
    fi
    
    [ -z "$target" ] && { echo -e "${RED}[!] No target${NC}"; read -p "Press Enter..."; return; }
    
    echo ""
    echo -e "${YELLOW}[🗡️] Running NMAP...${NC}"
    nmap "$target"
    
    read -p "Save loot? (y/n): " save
    [[ "$save" =~ ^[Yy]$ ]] && {
        read -p "Loot type: " type
        read -p "Loot value: " value
        add_loot "$type" "$value" "$target" "nmap"
    }
    
    read -p "Press Enter to continue..."
}

run_netdiscover() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Netdiscover ARP Scanner${NC}"
    echo ""
    
    if ! check_and_install_tool "netdiscover"; then
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Enter network range (e.g., 192.168.1.0/24): " network
    [ -z "$network" ] && { echo -e "${RED}[!] No network${NC}"; read -p "Press Enter..."; return; }
    
    echo ""
    echo -e "${YELLOW}[🗡️] Scanning network...${NC}"
    sudo netdiscover -r "$network"
    
    read -p "Press Enter to continue..."
}

run_nikto() {
    clear
    echo -e "${CYAN}${BOLD}[🥷] Nikto Web Scanner${NC}"
    echo -e "${WHITE}Default Target: ${BOLD}$TARGET_HOST:$TARGET_PORT${NC}${NC}"
    echo ""
    
    if ! check_and_install_tool "nikto"; then
        read -p "Press Enter to continue..."
        return
    fi
    
    read -p "Use current target? (y/n): " use_current
    
    local target
    local port
    if [[ "$use_current" =~ ^[