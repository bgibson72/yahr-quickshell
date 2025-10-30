#!/bin/bash
# List desktop applications for the launcher

# Blacklist - apps to hide (add desktop file basenames here)
BLACKLIST=(
    "xfce4-about.desktop"
    "avahi-discover.desktop"
    "bssh.desktop"
    "bvnc.desktop"
    "qv4l2.desktop"
    "qvidcap.desktop"
)

# Search paths for .desktop files (local first so overrides work)
SEARCH_PATHS=(
    "$HOME/.local/share/applications"
    "/usr/local/share/applications"
    "/usr/share/applications"
)

# Keep track of processed apps to avoid duplicates
declare -A processed_apps

# Function to find icon path
find_icon() {
    local icon_name="$1"
    
    # If it's already a path, return it
    if [[ "$icon_name" == /* ]]; then
        echo "$icon_name"
        return
    fi
    
    # Common icon sizes to try
    local sizes=(48 32 64 128 256)
    
    # Icon theme paths
    local icon_paths=(
        "$HOME/.local/share/icons"
        "$HOME/.icons"
        "/usr/share/icons"
        "/usr/share/pixmaps"
    )
    
    # Try to find the icon
    for path in "${icon_paths[@]}"; do
        # Try with extensions
        for ext in png svg xpm; do
            # Direct match in pixmaps
            if [ -f "$path/$icon_name.$ext" ]; then
                echo "$path/$icon_name.$ext"
                return
            fi
            
            # Try in hicolor theme with different sizes
            for size in "${sizes[@]}"; do
                if [ -f "$path/hicolor/${size}x${size}/apps/$icon_name.$ext" ]; then
                    echo "$path/hicolor/${size}x${size}/apps/$icon_name.$ext"
                    return
                fi
            done
        done
    done
    
    # If not found, just return the icon name
    echo "$icon_name"
}

# Process .desktop files
for dir in "${SEARCH_PATHS[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -name "*.desktop" -type f 2>/dev/null | while read -r desktop_file; do
            # Get basename for duplicate checking
            basename_file=$(basename "$desktop_file")
            
            # Skip if already processed (local overrides take precedence)
            if [[ -n "${processed_apps[$basename_file]}" ]]; then
                continue
            fi
            processed_apps[$basename_file]=1
            
            # Skip if in blacklist
            for blacklisted in "${BLACKLIST[@]}"; do
                if [[ "$basename_file" == "$blacklisted" ]]; then
                    continue 2
                fi
            done
            
            # Skip if NoDisplay=true
            if grep -q "^NoDisplay=true" "$desktop_file" 2>/dev/null; then
                continue
            fi
            
            # Extract fields
            name=$(grep "^Name=" "$desktop_file" | head -1 | cut -d= -f2-)
            comment=$(grep "^Comment=" "$desktop_file" | head -1 | cut -d= -f2-)
            icon=$(grep "^Icon=" "$desktop_file" | head -1 | cut -d= -f2-)
            exec=$(grep "^Exec=" "$desktop_file" | head -1 | cut -d= -f2- | sed 's/%[uUfF]//g' | sed 's/%[cdnNvmki]//g')
            
            # Skip if no name or exec
            [ -z "$name" ] && continue
            [ -z "$exec" ] && continue
            
            # Default comment if empty
            [ -z "$comment" ] && comment="Application"
            
            # Find icon path
            icon_path=$(find_icon "$icon")
            
            # Output in format: name|comment|icon_path|exec
            echo "$name|$comment|$icon_path|$exec"
        done
    fi
done | sort -u
