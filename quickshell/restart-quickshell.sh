#!/bin/bash
# Restart Quickshell

# Repair ThemeManager.qml if barLarge and uiFont were merged onto one line
THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
if grep -qE "barLarge.*property string uiFont" "$THEME_MANAGER" 2>/dev/null; then
    sed -i 's/\(property bool barLarge: [a-z]*\)[[:space:]]\{2,\}property string uiFont/\1\n    property string uiFont/' "$THEME_MANAGER"
    sed -i 's/\(property string uiFont: "[^"]*"\)}/\1\n}/' "$THEME_MANAGER"
fi

# Sync .current-theme to match ThemeManager.qml so the file is always in sync
# with what quickshell is actually showing. This prevents stale values from
# reverting the theme on the next startup.
THEME_NAME=$(grep -oP 'property string themeName: "\K[^"]+' "$THEME_MANAGER" 2>/dev/null)
if [ -n "$THEME_NAME" ]; then
    printf '%s' "$THEME_NAME" > "$HOME/.config/hypr/.current-theme"
fi

killall quickshell
sleep 0.5
quickshell &
