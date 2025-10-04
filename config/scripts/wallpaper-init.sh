#!/bin/bash

# VersionZero - Wallpaper Initialization
# Run at startup to set default wallpaper or restore per-workspace wallpapers

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CACHE_DIR="$HOME/.cache/versionzero/wallpapers"

# Wait for swww daemon to be ready
sleep 1

# Check if default wallpaper is saved
if [[ -f "$CACHE_DIR/default" ]]; then
    DEFAULT_WALLPAPER=$(cat "$CACHE_DIR/default")
    if [[ -f "$DEFAULT_WALLPAPER" ]]; then
        swww img "$DEFAULT_WALLPAPER" --transition-type fade --transition-duration 1
        exit 0
    fi
fi

# If no saved wallpaper, use random from wallpaper directory
if [[ -d "$WALLPAPER_DIR" ]] && [[ "$(ls -A "$WALLPAPER_DIR")" ]]; then
    RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    if [[ -n "$RANDOM_WALLPAPER" ]]; then
        swww img "$RANDOM_WALLPAPER" --transition-type fade --transition-duration 1
        echo "$RANDOM_WALLPAPER" > "$CACHE_DIR/default"
    fi
else
    # Fallback to solid color if no wallpapers found
    swww init
    swww img <(echo "P3\n1 1\n255\n31 28 44") --transition-type fade
fi
