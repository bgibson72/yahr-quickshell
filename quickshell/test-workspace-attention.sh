#!/bin/bash
# Test script for workspace attention highlighting

echo "Workspace Attention Test Script"
echo "================================"
echo ""
echo "This script helps test the workspace attention highlighting feature."
echo ""

# Get current workspace
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
echo "Current workspace: $current_ws"
echo ""

# Choose a test workspace (different from current)
if [ "$current_ws" -eq 1 ]; then
    test_ws=2
else
    test_ws=1
fi

echo "Test workspace will be: $test_ws"
echo ""

# Launch a terminal on the test workspace
echo "1. Launching kitty on workspace $test_ws..."
hyprctl dispatch workspace $test_ws
sleep 0.5
kitty &
test_pid=$!
sleep 1

# Get the window address
window_addr=$(hyprctl clients -j | jq -r ".[] | select(.pid == $test_pid) | .address")

if [ -z "$window_addr" ]; then
    echo "Error: Could not find window for kitty"
    exit 1
fi

echo "   Window address: $window_addr"
echo ""

# Go back to original workspace
echo "2. Returning to workspace $current_ws..."
hyprctl dispatch workspace $current_ws
sleep 0.5
echo ""

# Set the window as urgent
echo "3. Setting kitty window as URGENT..."
hyprctl setprop address:$window_addr urgent 1
echo ""

echo "✓ Test complete!"
echo ""
echo "Check your quickshell bar - workspace $test_ws should now be highlighted in RED"
echo ""
echo "The terminal window on workspace $test_ws is set to urgent state."
echo "You can:"
echo "  - Click workspace $test_ws in the bar to switch to it"
echo "  - The highlighting should disappear once you focus that window"
echo ""
echo "Press Enter to clean up (close test window and reset urgent state)..."
read

# Cleanup
echo "Cleaning up..."
hyprctl setprop address:$window_addr urgent 0
kill $test_pid 2>/dev/null
echo "Done!"
