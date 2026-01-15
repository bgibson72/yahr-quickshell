#!/bin/bash

# Show clipboard history using cliphist and wofi
cliphist list | wofi --dmenu --prompt "Clipboard History" | cliphist decode | wl-copy
