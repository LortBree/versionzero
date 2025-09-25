#!/bin/bash
# Menampilkan daftar aplikasi berjalan (window title)
hyprctl clients -j | jq -r '.[].title' | grep -v "^$" | paste -sd '  |  ' -