#!/bin/bash

# VersionZero - Brightness Control
# Backend for EWW brightness slider
# Usage: ./brightness-control.sh [get|set VALUE|up|down]

case "$1" in
    get)
        # Get current brightness percentage
        brightnessctl -m | cut -d',' -f4 | tr -d '%'
        ;;
    
    set)
        # Set brightness to specific value
        if [[ -n "$2" ]]; then
            brightnessctl set "$2%"
            notify-send -t 2000 -u low "Brightness" "Set to $2%"
        fi
        ;;
    
    up)
        # Increase brightness by 5%
        brightnessctl set 5%+
        CURRENT=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')
        notify-send -t 2000 -u low "Brightness" "Increased to ${CURRENT}%"
        ;;
    
    down)
        # Decrease brightness by 5%
        brightnessctl set 5%-
        CURRENT=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')
        notify-send -t 2000 -u low "Brightness" "Decreased to ${CURRENT}%"
        ;;
    
    *)
        echo "Usage: $0 [get|set VALUE|up|down]"
        exit 1
        ;;
esac