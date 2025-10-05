#!/bin/bash

# VersionZero - Night Light Toggle
# Uses gammastep for color temperature adjustment
# Manual toggle (no auto-schedule)

if pgrep -x gammastep > /dev/null; then
    # Night light is ON, turn it OFF
    pkill gammastep
    notify-send -t 2000 -u normal "Night Light" " Disabled"
else
    # Night light is OFF, turn it ON
    # Temperature: 3500K (warm, good for night viewing)
    # -O: One-shot mode (manual toggle, no schedule)
    gammastep -O 3500 &
    notify-send -t 2000 -u normal "Night Light" " Enabled (3500K)"
fi