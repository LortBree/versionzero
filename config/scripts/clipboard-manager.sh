#!/bin/bash

# VersionZero - Clipboard Manager
# Formats clipboard history for EWW dashboard
# Usage: ./clipboard-manager.sh [get|clear]

MAX_ITEMS=15
MAX_LENGTH=60

get_clipboard_html() {
    # Get clipboard history and format as HTML for EWW
    if ! command -v cliphist &>/dev/null; then
        echo "<box class='clip-empty'><label text='cliphist not installed' /></box>"
        return
    fi
    
    local count=0
    cliphist list 2>/dev/null | head -n "$MAX_ITEMS" | while IFS= read -r line; do
        count=$((count + 1))
        
        # Extract content (cliphist format: "id\tcontent" or just content)
        local content="${line}"
        
        # Truncate long content
        if [[ ${#content} -gt $MAX_LENGTH ]]; then
            content="${content:0:$MAX_LENGTH}..."
        fi
        
        # Escape special characters for HTML
        content=$(echo "$content" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g')
        
        # Check if it's an image
        if [[ "$content" == *"image/"* ]] || [[ "$content" == *"PNG"* ]] || [[ "$content" == *"JPEG"* ]]; then
            echo "<box class='clip-item clip-image' onclick='echo \"$line\" | cliphist decode | wl-copy'>"
            echo "  <label text='📷 Image' />"
            echo "</box>"
        else
            echo "<box class='clip-item' onclick='echo \"$line\" | cliphist decode | wl-copy'>"
            echo "  <label text='$content' limit-width='50' />"
            echo "</box>"
        fi
    done
    
    # If no items
    if [[ $(cliphist list 2>/dev/null | wc -l) -eq 0 ]]; then
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