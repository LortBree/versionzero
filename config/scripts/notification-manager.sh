#!/bin/bash

# VersionZero - Notification Manager
# Formats notification history for EWW dashboard
# Usage: ./notification-manager.sh [get|clear|toggle-dnd]

MAX_ITEMS=5

get_notifications_html() {
    # Check if mako is running
    if ! pidof -x mako > /dev/null 2>&1; then
        echo "<box class='notif-empty'>"
        echo "  <label text='Notification daemon not running' />"
        echo "</box>"
        return
    fi
    
    # Get notification list from mako
    NOTIFS=$(makoctl list 2>/dev/null)
    
    if [[ -z "$NOTIFS" ]] || [[ "$NOTIFS" == "[]" ]]; then
        echo "<box class='notif-empty'>"
        echo "  <label text='No notifications' />"
        echo "</box>"
        return
    fi
    
    # Parse JSON and format as HTML
    echo "$NOTIFS" | jq -r --arg max "$MAX_ITEMS" '
        .data[0:($max|tonumber)] | .[] | 
        "<box class=\"notif-item\" onclick=\"makoctl dismiss -n \(.id.data)\">
          <box orientation=\"v\">
            <label class=\"notif-app\" text=\"\(.appname.data)\" />
            <label class=\"notif-summary\" text=\"\(.summary.data)\" limit-width=\"40\" />
            <label class=\"notif-body\" text=\"\(.body.data)\" limit-width=\"50\" />
          </box>
        </box>"
    ' 2>/dev/null || echo "<box class='notif-error'><label text='Error loading notifications' /></box>"
}

clear_notifications() {
    makoctl dismiss --all
    notify-send -t 2000 "Notifications" "All notifications cleared"
}

toggle_dnd() {
    # Toggle Do Not Disturb mode
    if makoctl mode | grep -q "do-not-disturb"; then
        makoctl mode -r do-not-disturb
        notify-send -t 2000 "Do Not Disturb" "Disabled"
    else
        makoctl mode -a do-not-disturb
        notify-send -t 2000 "Do Not Disturb" "Enabled"
    fi
}

case "$1" in
    get)
        get_notifications_html
        ;;
    clear)
        clear_notifications
        ;;
    toggle-dnd)
        toggle_dnd
        ;;
    *)
        echo "Usage: $0 [get|clear|toggle-dnd]"
        exit 1
        ;;
esac