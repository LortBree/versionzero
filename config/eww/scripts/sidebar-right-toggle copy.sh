#!/bin/bash

# VersionZero - Sidebar Right (Dashboard) Smart Toggle
# Handles single/double click with state machine
# 
# State transitions:
# closed + 1x → page1
# closed + 2x → page2
# page1 + 1x → closed
# page1 + 2x → page2
# page2 + 1x → page1
# page2 + 2x → closed

STATE_FILE="/tmp/eww_dashboard_state"
CLICK_FILE="/tmp/eww_dashboard_click"
DOUBLE_CLICK_TIMEOUT=200  # milliseconds

# Initialize state file if doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo "closed" > "$STATE_FILE"
fi

# Read current state
CURRENT_STATE=$(cat "$STATE_FILE")

# Click detection logic
CURRENT_TIME=$(date +%s%3N)  # milliseconds

if [[ -f "$CLICK_FILE" ]]; then
    LAST_CLICK=$(cat "$CLICK_FILE")
    TIME_DIFF=$((CURRENT_TIME - LAST_CLICK))
    
    if [[ $TIME_DIFF -lt $DOUBLE_CLICK_TIMEOUT ]]; then
        # DOUBLE CLICK detected
        rm "$CLICK_FILE"  # Clear click file
        
        case "$CURRENT_STATE" in
            closed)
                # Open dashboard at page 2
                eww open sidebar-right
                eww update dashboard_page=1
                echo "page2" > "$STATE_FILE"
                ;;
            page1)
                # Go to page 2
                eww update dashboard_page=1
                echo "page2" > "$STATE_FILE"
                ;;
            page2)
                # Close dashboard
                eww close sidebar-right
                echo "closed" > "$STATE_FILE"
                ;;
        esac
        exit 0
    fi
fi

# First click or timeout passed → record timestamp and wait
echo "$CURRENT_TIME" > "$CLICK_FILE"

# Wait for potential second click
sleep 0.2

# Check if click file still exists (not consumed by double-click)
if [[ -f "$CLICK_FILE" ]]; then
    STORED_TIME=$(cat "$CLICK_FILE")
    if [[ "$STORED_TIME" == "$CURRENT_TIME" ]]; then
        # SINGLE CLICK confirmed (no second click came)
        rm "$CLICK_FILE"
        
        case "$CURRENT_STATE" in
            closed)
                # Open dashboard at page 1
                eww open sidebar-right
                eww update dashboard_page=0
                echo "page1" > "$STATE_FILE"
                ;;
            page1)
                # Close dashboard
                eww close sidebar-right
                echo "closed" > "$STATE_FILE"
                ;;
            page2)
                # Go back to page 1
                eww update dashboard_page=0
                echo "page1" > "$STATE_FILE"
                ;;
        esac
    fi
fi