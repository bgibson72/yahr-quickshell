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
    "lstopo.desktop"
    "uuctl.desktop"
    "codium.desktop"          # Hide regular VSCodium (keep Wayland version)
    "xgps.desktop"            # Hide Xgps
    "xgpsspeed.desktop"       # Hide Xgpsspeed
)

# Search paths for .desktop files (local first so overrides work)
SEARCH_PATHS=(
    "$HOME/.local/share/applications"
    "$HOME/.local/share/flatpak/exports/share/applications"
    "/var/lib/flatpak/exports/share/applications"
    "/usr/local/share/applications"
    "/usr/share/applications"
)

# Debug: Log search paths
echo "DEBUG: Searching in directories:" >&2
for p in "${SEARCH_PATHS[@]}"; do
    if [ -d "$p" ]; then
        count=$(find "$p" -name "*.desktop" -type f 2>/dev/null | wc -l)
        echo "  $p: $count files" >&2
    else
        echo "  $p: NOT FOUND" >&2
    fi
done

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

# Collect all desktop files and process, avoiding duplicates
# We use process substitution to avoid subshell issues with arrays
declare -A seen_apps

for dir in "${SEARCH_PATHS[@]}"; do
    [ ! -d "$dir" ] && continue
    
    while IFS= read -r desktop_file; do
        basename_file=$(basename "$desktop_file")
        
        # Skip duplicates (local overrides system)
        [[ -n "${seen_apps[$basename_file]}" ]] && continue
        seen_apps[$basename_file]=1
        
        # Skip blacklisted
        skip=0
        for blacklisted in "${BLACKLIST[@]}"; do
            if [[ "$basename_file" == "$blacklisted" ]]; then
                skip=1
                break
            fi
        done
        [[ $skip -eq 1 ]] && continue
        
        # Skip if NoDisplay=true
        grep -q "^NoDisplay=true" "$desktop_file" 2>/dev/null && continue
        
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
        
    done < <(find "$dir" -name "*.desktop" -type f 2>/dev/null)
done | sort -u
