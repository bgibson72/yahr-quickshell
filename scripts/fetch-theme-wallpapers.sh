#!/bin/bash

# ============================================
# Theme Wallpaper Fetcher for Wallhaven
# ============================================
# Fetches wallpapers matching your theme color palettes from Wallhaven.cc
# Usage: ./fetch-theme-wallpapers.sh [theme-name] [count]
# Example: ./fetch-theme-wallpapers.sh Catppuccin 20

set -e

# Configuration
THEMES_DIR="$HOME/.config/hypr/themes"
WALLPAPERS_BASE="$HOME/Pictures/Themes"
DEFAULT_COUNT=20
MIN_RESOLUTION="1920x1080"
WALLHAVEN_API="https://wallhaven.cc/api/v1/search"

# Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Help function
show_help() {
    cat << EOF
${BOLD}Theme Wallpaper Fetcher${NC}

Fetches wallpapers from Wallhaven.cc matching your theme color palette.

${BOLD}Usage:${NC}
    $0 [theme-name] [count]
    $0 --list
    $0 --all [count]

${BOLD}Arguments:${NC}
    theme-name    Name of theme (e.g., Catppuccin, Dracula, Nord)
    count         Number of wallpapers to fetch per color (default: 5)

${BOLD}Options:${NC}
    --list        List available themes
    --all         Fetch wallpapers for all themes
    -h, --help    Show this help message

${BOLD}Examples:${NC}
    $0 Catppuccin 20          # Fetch 20 wallpapers for Catppuccin theme
    $0 Dracula                # Fetch 5 wallpapers (default) for Dracula
    $0 --all 10               # Fetch 10 wallpapers for each theme

${BOLD}Note:${NC}
    Wallpapers are saved to: ~/Pictures/Themes/[ThemeName]/
    You can delete unwanted images at your leisure.

EOF
}

# List available themes
list_themes() {
    echo -e "${BOLD}Available themes:${NC}"
    for theme_file in "$THEMES_DIR"/*.conf; do
        theme_name=$(basename "$theme_file" .conf)
        if [[ "$theme_name" != "active-theme" ]]; then
            echo "  - $theme_name"
        fi
    done
}

# Extract hex colors from theme file
extract_colors() {
    local theme_file="$1"
    local colors=()
    
    # Extract unique hex colors (6 characters, without rgb() wrapper)
    while IFS= read -r line; do
        if [[ $line =~ \$accent.*=\ rgb\(([0-9a-fA-F]{6})\) ]]; then
            color="${BASH_REMATCH[1]}"
            # Only add unique colors
            if [[ ! " ${colors[@]} " =~ " ${color} " ]]; then
                colors+=("$color")
            fi
        fi
    done < "$theme_file"
    
    # Limit to top 5 most distinctive colors for better results
    echo "${colors[@]:0:5}"
}

# Fetch wallpapers from Wallhaven for a single color
fetch_by_color() {
    local color="$1"
    local output_dir="$2"
    local count="$3"
    
    echo -e "  ${BLUE}→${NC} Searching for color #${color}..."
    
    # Build API request URL
    local url="${WALLHAVEN_API}?colors=${color}&categories=111&purity=100&sorting=random&atleast=${MIN_RESOLUTION}&page=1"
    
    # Fetch search results
    local response=$(curl -s "$url")
    
    # Parse image URLs using grep and sed (no jq dependency)
    local image_urls=$(echo "$response" | grep -o '"path":"[^"]*"' | sed 's/"path":"//g' | sed 's/"//g' | head -n "$count")
    
    if [[ -z "$image_urls" ]]; then
        echo -e "    ${YELLOW}No results found${NC}"
        return
    fi
    
    # Download each image
    local downloaded=0
    while IFS= read -r image_url; do
        if [[ -n "$image_url" ]]; then
            local filename=$(basename "$image_url")
            local filepath="$output_dir/$filename"
            
            # Skip if already exists
            if [[ -f "$filepath" ]]; then
                echo -e "    ${YELLOW}⊘${NC} Skipping $filename (already exists)"
                continue
            fi
            
            # Download with progress
            if curl -s -o "$filepath" "$image_url"; then
                ((downloaded++))
                echo -e "    ${GREEN}✓${NC} Downloaded $filename"
            else
                echo -e "    ${RED}✗${NC} Failed to download $filename"
            fi
        fi
    done <<< "$image_urls"
    
    echo -e "    ${GREEN}Downloaded $downloaded wallpaper(s)${NC}"
}

# Main function to fetch wallpapers for a theme
fetch_theme_wallpapers() {
    local theme_name="$1"
    local count_per_color="${2:-5}"
    
    local theme_file="$THEMES_DIR/${theme_name}.conf"
    
    if [[ ! -f "$theme_file" ]]; then
        echo -e "${RED}Error: Theme file not found: $theme_file${NC}"
        return 1
    fi
    
    echo -e "${BOLD}Fetching wallpapers for ${GREEN}$theme_name${NC}${BOLD} theme...${NC}"
    
    # Create output directory
    local output_dir="$WALLPAPERS_BASE/$theme_name"
    mkdir -p "$output_dir"
    
    # Extract colors
    local colors=($(extract_colors "$theme_file"))
    
    if [[ ${#colors[@]} -eq 0 ]]; then
        echo -e "${RED}Error: No colors found in theme file${NC}"
        return 1
    fi
    
    echo -e "Found ${#colors[@]} colors to search: ${colors[*]}"
    echo ""
    
    # Fetch wallpapers for each color
    for color in "${colors[@]}"; do
        fetch_by_color "$color" "$output_dir" "$count_per_color"
        sleep 1  # Be nice to the API
    done
    
    echo ""
    echo -e "${GREEN}✓ Complete!${NC} Wallpapers saved to: ${BOLD}$output_dir${NC}"
    echo -e "  Review and delete any you don't like."
}

# Fetch for all themes
fetch_all_themes() {
    local count_per_color="${1:-5}"
    
    echo -e "${BOLD}Fetching wallpapers for all themes...${NC}"
    echo ""
    
    for theme_file in "$THEMES_DIR"/*.conf; do
        theme_name=$(basename "$theme_file" .conf)
        if [[ "$theme_name" != "active-theme" ]]; then
            fetch_theme_wallpapers "$theme_name" "$count_per_color"
            echo ""
            echo "---"
            echo ""
        fi
    done
    
    echo -e "${GREEN}✓ All themes complete!${NC}"
}

# Main script logic
main() {
    # Check for required commands
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is required but not installed${NC}"
        exit 1
    fi
    
    # Parse arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        --list)
            list_themes
            exit 0
            ;;
        --all)
            fetch_all_themes "${2:-5}"
            exit 0
            ;;
        "")
            echo -e "${RED}Error: No theme specified${NC}"
            echo ""
            show_help
            exit 1
            ;;
        *)
            fetch_theme_wallpapers "$1" "${2:-5}"
            ;;
    esac
}

main "$@"
