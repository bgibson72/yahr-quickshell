#!/bin/bash
# Quick helper to add a new class to the Vencord theme sync script

CLASS_NAME="$1"

if [ -z "$CLASS_NAME" ]; then
    echo "Usage: $0 <class-name>"
    echo ""
    echo "Example: $0 someClass_abc123"
    echo ""
    echo "This will add the class to the app background section of sync-vencord-theme.sh"
    exit 1
fi

# Remove leading dot if provided
CLASS_NAME="${CLASS_NAME#.}"

SYNC_SCRIPT="$HOME/.config/quickshell/sync-vencord-theme.sh"

# Check if class already exists
if grep -q "\.${CLASS_NAME}" "$SYNC_SCRIPT"; then
    echo "⚠ Class '.${CLASS_NAME}' already exists in the sync script"
    exit 0
fi

# Find the line with .wrapper_a7e7a8 and add the new class after it
sed -i "/\.wrapper_a7e7a8 {/i\.${CLASS_NAME}," "$SYNC_SCRIPT"

echo "✓ Added '.${CLASS_NAME}' to the app background section"
echo ""
echo "Now regenerate the theme:"
echo "  ~/.config/quickshell/sync-vencord-theme.sh --theme-file"
echo ""
echo "Then reload Vesktop (Ctrl+R)"
