#!/bin/bash

# Bar Switcher - Switch between Waybar and Quickshell
# Usage: ./bar-switcher.sh [waybar|quickshell]

set -e

CHOICE="$1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}    Status Bar Switcher${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to check what's running
check_running() {
    if pgrep -x waybar > /dev/null; then
        echo -e "${GREEN}✓${NC} Waybar is running"
        WAYBAR_RUNNING=true
    else
        echo -e "  Waybar is not running"
        WAYBAR_RUNNING=false
    fi
    
    if pgrep -x quickshell > /dev/null; then
        echo -e "${GREEN}✓${NC} Quickshell is running"
        QUICKSHELL_RUNNING=true
    else
        echo -e "  Quickshell is not running"
        QUICKSHELL_RUNNING=false
    fi
}

# Function to start Waybar
start_waybar() {
    echo -e "\n${YELLOW}Stopping Quickshell...${NC}"
    killall quickshell 2>/dev/null || true
    sleep 0.5
    
    echo -e "${YELLOW}Starting Waybar...${NC}"
    waybar &
    sleep 1
    
    if pgrep -x waybar > /dev/null; then
        echo -e "${GREEN}✓ Waybar started successfully!${NC}"
    else
        echo -e "${RED}✗ Failed to start Waybar${NC}"
        exit 1
    fi
}

# Function to start Quickshell
start_quickshell() {
    echo -e "\n${YELLOW}Stopping Waybar...${NC}"
    killall waybar 2>/dev/null || true
    sleep 0.5
    
    echo -e "${YELLOW}Starting Quickshell...${NC}"
    quickshell &
    sleep 1
    
    if pgrep -x quickshell > /dev/null; then
        echo -e "${GREEN}✓ Quickshell started successfully!${NC}"
    else
        echo -e "${RED}✗ Failed to start Quickshell${NC}"
        exit 1
    fi
}

# Main logic
echo "Current status:"
check_running
echo ""

if [ -z "$CHOICE" ]; then
    echo "Which status bar would you like to use?"
    echo "  1) Waybar"
    echo "  2) Quickshell"
    echo ""
    read -p "Enter choice (1 or 2): " CHOICE_NUM
    
    case $CHOICE_NUM in
        1) CHOICE="waybar" ;;
        2) CHOICE="quickshell" ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
fi

case "$CHOICE" in
    waybar)
        if $WAYBAR_RUNNING; then
            echo -e "${YELLOW}Waybar is already running${NC}"
        else
            start_waybar
        fi
        ;;
    quickshell)
        if $QUICKSHELL_RUNNING; then
            echo -e "${YELLOW}Quickshell is already running${NC}"
        else
            start_quickshell
        fi
        ;;
    *)
        echo -e "${RED}Invalid option: $CHOICE${NC}"
        echo "Usage: $0 [waybar|quickshell]"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}    Done!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
