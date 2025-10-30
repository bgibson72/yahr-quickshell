#!/bin/bash

echo "=== Testing Flatpak app discovery ==="

FLATPAK_DIR="/var/lib/flatpak/exports/share/applications"

echo "Directory exists: $([ -d "$FLATPAK_DIR" ] && echo YES || echo NO)"
echo ""

echo "Files in directory:"
ls -1 "$FLATPAK_DIR" 2>&1
echo ""

echo "Desktop files found by find:"
find "$FLATPAK_DIR" -name "*.desktop" -type f 2>&1
echo ""

echo "=== Processing with script logic ==="
while IFS= read -r desktop_file; do
    echo "Processing: $desktop_file"
    name=$(grep "^Name=" "$desktop_file" | head -1 | cut -d= -f2-)
    echo "  Name: $name"
done < <(find "$FLATPAK_DIR" -name "*.desktop" -type f 2>/dev/null)
