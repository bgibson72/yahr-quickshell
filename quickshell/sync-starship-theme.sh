#!/bin/bash

# Sync Starship Prompt Colors with Current Quickshell Theme
# Reads colors from ThemeManager.qml and updates starship.toml

THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
STARSHIP_CONFIG="$HOME/.config/starship.toml"
STARSHIP_BACKUP="$HOME/.config/starship.toml.backup"

# Check if ThemeManager exists
if [[ ! -f "$THEME_MANAGER" ]]; then
    echo "Error: ThemeManager.qml not found at $THEME_MANAGER"
    exit 1
fi

# Extract theme colors
theme_name=$(grep 'property string themeName:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_blue=$(grep 'property color accentBlue:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_cyan=$(grep 'property color accentCyan:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_green=$(grep 'property color accentGreen:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
accent_yellow=$(grep 'property color accentYellow:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_primary=$(grep 'property color fgPrimary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
fg_secondary=$(grep 'property color fgSecondary:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
bg_base=$(grep 'property color bgBase:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
surface0=$(grep 'property color surface0:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')
surface1=$(grep 'property color surface1:' "$THEME_MANAGER" | sed -E 's/.*"([^"]+)".*/\1/')

# Fallback to cyan if blue doesn't exist
if [[ -z "$accent_blue" ]]; then
    accent_blue="$accent_cyan"
fi

echo "Syncing Starship colors for theme: $theme_name"

# Backup existing config
if [[ -f "$STARSHIP_CONFIG" ]]; then
    cp "$STARSHIP_CONFIG" "$STARSHIP_BACKUP"
fi

# Create new starship config with theme colors
cat > "$STARSHIP_CONFIG" << EOF
# Starship Prompt Configuration
# Auto-synced with Quickshell Theme: $theme_name

format = """\
[](bg:$bg_base fg:$accent_green)\
[󰣇 ](bg:$accent_green fg:$bg_base)\
[](fg:$accent_green bg:$surface0)\
\$time\
[](fg:$surface0 bg:$accent_blue)\
\$directory\
[](fg:$accent_blue bg:$accent_yellow)\
\$git_branch\
\$git_status\
\$git_metrics\
[](fg:$accent_yellow bg:$bg_base)\
\$character\
"""

[directory]
format = "[  \$path ](\$style)"
style = "fg:$bg_base bg:$accent_blue"

[git_branch]
format = '[ \$symbol\$branch(:\$remote_branch) ](\$style)'
symbol = "  "
style = "fg:$bg_base bg:$accent_yellow"

[git_status]
format = '[\$all_status](\$style)'
style = "fg:$bg_base bg:$accent_yellow"

[git_metrics]
format = "([+\$added](\$added_style))[](\$added_style)"
added_style = "fg:$bg_base bg:$accent_yellow"
deleted_style = "fg:$bg_base bg:$accent_yellow"
disabled = false

[hg_branch]
format = "[ \$symbol\$branch ](\$style)"
symbol = " "

[cmd_duration]
format = "[ 󱎫 \$duration ](\$style)"
style = "fg:$fg_primary bg:$surface1"

[character]
success_symbol = '[ ➜](bold $accent_green) '
error_symbol = '[ ✗](bold red) '

[time]
disabled = false
time_format = "%R"
style = "bg:$surface1"
format = '[[ 󱑍 \$time ](bg:$surface0 fg:$accent_cyan)](\$style)'
EOF

echo "✓ Starship configuration updated with $theme_name colors"
echo "  Accent Blue: $accent_blue"
echo "  Accent Green: $accent_green"
echo "  Accent Yellow: $accent_yellow"
echo "  Accent Cyan: $accent_cyan"
echo ""
echo "Restart your terminal or run: source ~/.zshrc"
