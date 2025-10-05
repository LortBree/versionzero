#!/bin/bash

# VersionZero - Audio Popup Controller
# Toggle audio control popup (similar to Windows)
# Shows volume slider and output device selector
# Usage: ./audio-popup.sh [toggle|show|hide]

POPUP_STATE="/tmp/audio_popup_state"

show_popup() {
    # Launch pavucontrol in floating mode
    if ! pgrep -x pavucontrol > /dev/null; then
        pavucontrol &
        echo "visible" > "$POPUP_STATE"
    fi
}

hide_popup() {
    pkill pavucontrol
    rm -f "$POPUP_STATE"
}

toggle_popup() {
    if [[ -f "$POPUP_STATE" ]]; then
        hide_popup
    else
        show_popup
    fi
}

case "$1" in
    show)
        show_popup
        ;;
    hide)
        hide_popup
        ;;
    toggle|*)
        toggle_popup
        ;;
esac