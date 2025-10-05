#!/bin/bash

# VersionZero - Wallpaper Selector
# Wofi-based wallpaper picker with preview thumbnails
# Supports per-workspace wallpaper

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/versionzero/wallpapers"
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Create directories if they don't exist
mkdir -p "$WALLPAPER_DIR"
mkdir -p "$CACHE_DIR"

# Check if wallpaper directory has images
if [[ ! "$(ls -A "$WALLPAPER_DIR")" ]]; then
    notify-send -u critical "Wallpaper Selector" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Generate list of wallpapers with full paths
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) -printf "%f\n" | sort)

if [[ -z "$WALLPAPERS" ]]; then
    notify-send -u critical "Wallpaper Selector" "No valid image files found"
    exit 1
fi

# Show wofi selector (wofi automatically loads ~/.config/wofi/style.css)
SELECTED=$(echo "$WALLPAPERS" | wofi --dmenu --prompt "Select Wallpaper")

if [[ -n "$SELECTED" ]]; then
    WALLPAPER_PATH="$WALLPAPER_DIR/$SELECTED"
    
    # Ask if user wants to apply to all workspaces or current only
    SCOPE=$(echo -e "Current Workspace\nAll Workspaces" | wofi --dmenu --prompt "Apply to" --style "$HOME/.config/wofi/style.css")
    
    if [[ "$SCOPE" == "Current Workspace" ]]; then
        # Apply to current workspace only
        swww img "$WALLPAPER_PATH" --transition-type fade --transition-duration 1
        
        # Save per-workspace wallpaper config
        echo "$WALLPAPER_PATH" > "$CACHE_DIR/workspace_${CURRENT_WS}"
        
        notify-send -t 2000 "Wallpaper" "Applied to workspace $CURRENT_WS"
    else
        # Apply to all workspaces
        swww img "$WALLPAPER_PATH" --transition-type fade --transition-duration 1
        
        # Save as default wallpaper
        echo "$WALLPAPER_PATH" > "$CACHE_DIR/default"
        
        # Clear per-workspace configs
        rm -f "$CACHE_DIR"/workspace_* 2>/dev/null || true
        
        notify-send -t 2000 "Wallpaper" "Applied to all workspaces"
    fi
fi