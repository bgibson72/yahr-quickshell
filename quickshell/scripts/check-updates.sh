#!/bin/bash

# Check for updates script
# Based on ML4W updates.sh but simplified for Quickshell

# Check if command exists
_checkCommandExists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for lock files
check_lock_files() {
    local pacman_lock="/var/lib/pacman/db.lck"
    local checkup_lock="${TMPDIR:-/tmp}/checkup-db-${UID}/db.lck"
    
    # Wait up to 30 seconds for locks to clear
    local timeout=30
    local elapsed=0
    
    while [ -f "$pacman_lock" ] || [ -f "$checkup_lock" ]; do
        if [ $elapsed -ge $timeout ]; then
            echo "0"
            exit 1
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
}

# Main update check
if _checkCommandExists "pacman"; then
    # Check for lock files first
    check_lock_files
    
    # Check for AUR helper
    aur_helper=""
    if _checkCommandExists "paru"; then
        aur_helper="paru"
    elif _checkCommandExists "yay"; then
        aur_helper="yay"
    fi
    
    # Get official repo updates
    if _checkCommandExists "checkupdates"; then
        updates_pacman=$(checkupdates 2>/dev/null | wc -l)
    else
        updates_pacman=$(pacman -Qu 2>/dev/null | wc -l)
    fi
    
    # Get AUR updates if helper is available
    updates_aur=0
    if [ -n "$aur_helper" ]; then
        updates_aur=$($aur_helper -Qua 2>/dev/null | wc -l)
    fi
    
    # Total updates
    updates=$((updates_pacman + updates_aur))
    echo "$updates"
    
elif _checkCommandExists "dnf"; then
    # Fedora
    updates=$(dnf check-update -q 2>/dev/null | grep -c ^[a-z0-9])
    echo "$updates"
else
    echo "0"
fi
