# VersionZero Theme Switcher Function for Fish Shell
# Quick access to theme switching from terminal
# Usage: theme [1|2|3|next|midnight|ocean|cyberpunk]

function theme
    set -l theme_arg $argv[1]
    
    # Show help if no argument
    if test (count $argv) -eq 0
        echo "VersionZero Theme Switcher"
        echo ""
        echo "Usage: theme [OPTION]"
        echo ""
        echo "Options:"
        echo "  1, midnight    - Switch to Midnight Elegance theme"
        echo "  2, ocean       - Switch to Ocean Breeze theme"
        echo "  3, cyberpunk   - Switch to Cyberpunk Dreams theme"
        echo "  next           - Cycle to next theme"
        echo ""
        echo "Current theme: "(cat ~/.config/colors/current-theme 2>/dev/null || echo "unknown")
        return 0
    end
    
    # Map friendly names to theme IDs
    switch $theme_arg
        case 1 midnight
            set theme_id theme1
        case 2 ocean
            set theme_id theme2
        case 3 cyberpunk
            set theme_id theme3
        case next
            set theme_id next
        case '*'
            echo "Invalid theme: $theme_arg"
            echo "Valid options: 1/midnight, 2/ocean, 3/cyberpunk, next"
            return 1
    end
    
    # Execute theme switcher
    ~/.config/scripts/theme-switcher.sh $theme_id
    
    # Reload fish config to apply new colors
    source ~/.config/fish/config.fish
end