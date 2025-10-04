#!/bin/bash

# VersionZero - Clipboard Manager
# Formats clipboard history for EWW dashboard
# Usage: ./clipboard-manager.sh [get|clear]

MAX_ITEMS=15
MAX_LENGTH=60

get_clipboard_html() {
    # Get clipboard history and format as HTML for EWW
    cliphist list | head -n "$MAX_ITEMS" | while IFS=$'\t' read -r id content; do
        # Truncate long content
        if [[ ${#content} -gt $MAX_LENGTH ]]; then
            content="${content:0:$MAX_LENGTH}..."
        fi
        
        # Escape special characters for HTML
        content=$(echo "$content" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')
        
        # Check if it's an image (base64 encoded)
        if [[ "$content" == *"image/png"* ]] || [[ "$content" == *"image/jpeg"* ]]; then
            echo "<box class='clip-item clip-image'>"
            echo "  <label text='📷 Image' />"
            echo "</box>"
        else
            echo "<box class='clip-item' onclick='cliphist decode &lt;&lt;&lt;$id | wl-copy'>"
            echo "  <label text='$content' limit-width='50' />"
            echo "</box>"
        fi
    done
    
    # If no items
    if [[ $(cliphist list | wc -l) -eq 0 ]]; then
        echo "<box class='clip-empty'>"
        echo "  <label text='No clipboard history' />"
        echo "</box>"
    fi
}

clear_clipboard() {
    cliphist wipe
    notify-send -t 2000 "Clipboard" "History cleared"
}

case "$1" in
    get)
        get_clipboard_html
        ;;
    clear)
        clear_clipboard
        ;;
    *)
        echo "Usage: $0 [get|clear]"
        exit 1
        ;;
esac
