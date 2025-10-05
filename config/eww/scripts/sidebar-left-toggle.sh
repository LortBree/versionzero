#!/bin/bash

# VersionZero - Sidebar Left (Dock) Toggle
# Slide in from left, slide out to left

STATE_FILE="/tmp/eww_sidebar_left_state"

# Check current state
if [[ -f "$STATE_FILE" ]]; then
    # Currently visible, hide it
    eww close sidebar-left
    rm "$STATE_FILE"
else
    # Currently hidden, show it
    eww open sidebar-left
    echo "visible" > "$STATE_FILE"
fi