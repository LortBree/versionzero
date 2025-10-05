#!/bin/bash

# VersionZero - System Information Script
# Provides CPU, GPU, RAM usage and temperature data for EWW widgets
# Usage: ./system-info.sh [cpu|gpu|ram|temp]

case "$1" in
    cpu)
        # Get CPU usage percentage
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        printf "%.0f" "$cpu_usage"
        ;;
    
    gpu)
        # Try to get GPU usage (NVIDIA first, then AMD)
        if command -v nvidia-smi &>/dev/null; then
            nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0"
        elif [[ -f /sys/class/drm/card0/device/gpu_busy_percent ]]; then
            cat /sys/class/drm/card0/device/gpu_busy_percent
        else
            echo "0"
        fi
        ;;
    
    ram)
        # Get RAM usage percentage
        free | grep Mem | awk '{printf "%.0f", ($3/$2) * 100}'
        ;;
    
    temp)
        # Get CPU temperature
        if command -v sensors &>/dev/null; then
            sensors | grep -i "Package id 0:" | awk '{print $4}' | tr -d '+°C' || echo "0"
        elif [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
            awk '{printf "%.0f", $1/1000}' /sys/class/thermal/thermal_zone0/temp
        else
            echo "0"
        fi
        ;;
    
    *)
        echo "Usage: $0 [cpu|gpu|ram|temp]"
        exit 1
        ;;
esac