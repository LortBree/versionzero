#!/bin/bash

# VersionZero - Screenshot Utility
# Uses grim + slurp for Wayland screenshots
# Usage: ./screenshot.sh [area|full|window]

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="screenshot_${TIMESTAMP}.png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# Create directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

case "$1" in
    area)
        # Screenshot selected area
        grim -g "$(slurp)" "$FILEPATH"
        if [[ $? -eq 0 ]]; then
            notify-send -t 3000 -i "$FILEPATH" "Screenshot" "Area captured\n$FILENAME"
            wl-copy < "$FILEPATH"
        fi
        ;;
    
    full)
        # Screenshot full screen
        grim "$FILEPATH"
        if [[ $? -eq 0 ]]; then
            notify-send -t 3000 -i "$FILEPATH" "Screenshot" "Full screen captured\n$FILENAME"
            wl-copy < "$FILEPATH"
        fi
        ;;
    
    window)
        # Screenshot active window
        WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        if [[ -n "$WINDOW_GEOMETRY" ]]; then
            grim -g "$WINDOW_GEOMETRY" "$FILEPATH"
            if [[ $? -eq 0 ]]; then
                notify-send -t 3000 -i "$FILEPATH" "Screenshot" "Window captured\n$FILENAME"
                wl-copy < "$FILEPATH"
            fi
        else
            notify-send -u critical "Screenshot" "Failed to get window geometry"
        fi
        ;;
    
    *)
        echo "Usage: $0 [area|full|window]"
        echo "  area   - Select area to capture"
        echo "  full   - Capture entire screen"
        echo "  window - Capture active window"
        exit 1
        ;;
esac