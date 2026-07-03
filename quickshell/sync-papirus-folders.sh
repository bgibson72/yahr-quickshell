#!/bin/bash

# Sync Papirus Folder Colors with Current Theme
#
# papirus-folders only supports a fixed palette of named colors (it doesn't
# accept arbitrary hex values), so instead of guessing a "closest vibe" color
# per theme name, this computes the actual nearest-neighbor match (in RGB
# space) between the current theme's real accent color ($accent-blue) and
# every color papirus-folders offers, using the exact hex value baked into
# each color's folder SVG asset. This keeps folder colors correctly in sync
# even if a theme's palette (e.g. Material) changes in the future.

CURRENT_THEME_FILE="$HOME/.config/hypr/.current-theme"
HYPR_THEMES_DIR="$HOME/.config/hypr/themes"

# Check if papirus-folders is available
if ! command -v papirus-folders &> /dev/null; then
    echo "Error: papirus-folders command not found"
    echo "Install with: sudo pacman -S papirus-icon-theme"
    exit 1
fi

# Check if current theme file exists
if [[ ! -f "$CURRENT_THEME_FILE" ]]; then
    echo "Error: Current theme file not found at $CURRENT_THEME_FILE"
    exit 1
fi

theme_name=$(cat "$CURRENT_THEME_FILE" | tr -d '[:space:]')
THEME_FILE="$HYPR_THEMES_DIR/${theme_name}.conf"

if [[ ! -f "$THEME_FILE" ]]; then
    echo "Error: Theme file not found: $THEME_FILE"
    exit 1
fi

accent_hex=$(grep '^\$accent-blue' "$THEME_FILE" | sed -E 's/.*= *rgb\(([^)]+)\).*/\1/' | head -1)
if [[ -z "$accent_hex" ]]; then
    echo "Error: Could not read \$accent-blue from $THEME_FILE"
    exit 1
fi

echo "Matching Papirus folder color to $theme_name's accent (#$accent_hex)"

# Ground-truth hex values extracted directly from each color's base
# folder-<color>.svg asset in Papirus-Dark/24x24/places.
declare -A palette=(
    [adwaita]="93c0ea"   [black]="dcdcdc"     [blue]="5294e2"
    [bluegrey]="607d8b"  [breeze]="57b8ec"    [brown]="ae8e6c"
    [carmine]="a30002"   [cyan]="00bcd4"      [darkcyan]="45abb7"
    [deeporange]="eb6637" [green]="87b158"    [grey]="8e8e8e"
    [indigo]="5c6bc0"    [magenta]="ca71df"   [nordic]="eceff4"
    [orange]="ee923a"    [palebrown]="d1bfae" [paleorange]="eeca8f"
    [pink]="f06292"      [red]="e25252"       [teal]="16a085"
    [violet]="7e57c2"    [white]="cccccc"     [yaru]="ff7446"
    [yellow]="f9bd30"
)

target_r=$((16#${accent_hex:0:2}))
target_g=$((16#${accent_hex:2:2}))
target_b=$((16#${accent_hex:4:2}))

best_color=""
best_distance=999999999

for name in "${!palette[@]}"; do
    hex="${palette[$name]}"
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    dr=$((r - target_r))
    dg=$((g - target_g))
    db=$((b - target_b))
    distance=$(( dr*dr + dg*dg + db*db ))
    if (( distance < best_distance )); then
        best_distance=$distance
        best_color=$name
    fi
done

folder_color="$best_color"
echo "Nearest Papirus folder color: $folder_color (#${palette[$folder_color]})"

# Apply the folder color
# Note: papirus-folders requires sudo to modify system icon files.
# For passwordless operation, add to /etc/sudoers.d/papirus-folders:
# %wheel ALL=(ALL) NOPASSWD: /usr/bin/papirus-folders
sudo papirus-folders -C "$folder_color" --theme Papirus-Dark 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Successfully updated Papirus folder colors to $folder_color"
else
    echo "Note: papirus-folders requires sudo permissions"
    echo "For automatic updates, add this to /etc/sudoers.d/papirus-folders:"
    echo "  %wheel ALL=(ALL) NOPASSWD: /usr/bin/papirus-folders"
    exit 1
fi
