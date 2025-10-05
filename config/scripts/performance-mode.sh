#!/bin/bash

# VersionZero - Performance Mode Switcher
# Cycles through CPU governor modes: powersave → balanced → performance
# Usage: ./performance-mode.sh [next|get|set MODE]

CURRENT_GOVERNOR=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)

get_mode() {
    case "$CURRENT_GOVERNOR" in
        powersave)
            echo "save"
            ;;
        schedutil|ondemand)
            echo "balance"
            ;;
        performance)
            echo "performance"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

set_mode() {
    local mode=$1
    local governor=""
    local icon=""
    
    case "$mode" in
        save|powersave)
            governor="powersave"
            icon="󰾅"
            ;;
        balance|balanced)
            # Use schedutil if available, otherwise ondemand
            if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]]; then
                if grep -q "schedutil" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors; then
                    governor="schedutil"
                else
                    governor="ondemand"
                fi
            else
                governor="ondemand"
            fi
            icon=""
            ;;
        performance|perf)
            governor="performance"
            icon=""
            ;;
        *)
            echo "Invalid mode: $mode"
            echo "Valid modes: save, balance, performance"
            exit 1
            ;;
    esac
    
    # Set governor for all CPUs (requires sudo, but configured in sudoers for NOPASSWD)
    # User should add to /etc/sudoers.d/cpupower:
    # %wheel ALL=(ALL) NOPASSWD: /usr/bin/cpupower
    
    if command -v cpupower &>/dev/null; then
        sudo cpupower frequency-set -g "$governor" > /dev/null 2>&1 || {
            # Fallback to manual method if cpupower fails
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null; do
                echo "$governor" | sudo tee "$cpu" > /dev/null 2>&1
            done
        }
    else
        # Manual method without cpupower
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null; do
            echo "$governor" | sudo tee "$cpu" > /dev/null 2>&1
        done
    fi
    
    notify-send -t 3000 -u normal "Performance Mode" "$icon Mode: $(echo $governor | tr '[:lower:]' '[:upper:]')"
}

case "$1" in
    get)
        get_mode
        ;;
    
    set)
        if [[ -n "$2" ]]; then
            set_mode "$2"
        else
            echo "Usage: $0 set [save|balance|performance]"
            exit 1
        fi
        ;;
    
    next)
        current=$(get_mode)
        case "$current" in
            save)
                set_mode "balance"
                ;;
            balance)
                set_mode "performance"
                ;;
            performance)
                set_mode "save"
                ;;
            *)
                set_mode "balance"
                ;;
        esac
        ;;
    
    *)
        echo "Usage: $0 [next|get|set MODE]"
        echo "Modes: save, balance, performance"
        exit 1
        ;;
esac