#!/bin/bash
# Restart Quickshell

# Repair ThemeManager.qml if barLarge and uiFont were merged onto one line
THEME_MANAGER="$HOME/.config/quickshell/ThemeManager.qml"
if grep -qE "barLarge.*property string uiFont" "$THEME_MANAGER" 2>/dev/null; then
    sed -i 's/\(property bool barLarge: [a-z]*\)[[:space:]]\{2,\}property string uiFont/\1\n    property string uiFont/' "$THEME_MANAGER"
    sed -i 's/\(property string uiFont: "[^"]*"\)}/\1\n}/' "$THEME_MANAGER"
fi

killall quickshell
sleep 0.5
quickshell &
