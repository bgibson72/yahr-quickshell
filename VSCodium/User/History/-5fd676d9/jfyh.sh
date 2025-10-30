#!/bin/bash
# List desktop applications for the launcher

# Search paths for .desktop files
SEARCH_PATHS=(
    "/usr/share/applications"
    "/usr/local/share/applications"
    "$HOME/.local/share/applications"
)

# Process .desktop files
for dir in "${SEARCH_PATHS[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -name "*.desktop" -type f 2>/dev/null | while read -r desktop_file; do
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
            
            # Output in format: name|comment|icon|exec
            echo "$name|$comment|$icon|$exec"
        done
    fi
done | sort -u
