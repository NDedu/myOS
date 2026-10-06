#!/bin/bash

# Laptop display brightness with the pop-up: niri's default 10% steps, never below 1%
# Usage: brightness.sh +10%|10%-

# The floor is a raw value (1% of this panel's maximum); brightnessctl reads "1%" as 1
max=$(brightnessctl --class=backlight max)
brightnessctl --class=backlight --min-value=$((max / 100 > 1 ? max / 100 : 1)) set "${1:-+10%}" >/dev/null

percent=$(brightnessctl --class=backlight -m | cut -d',' -f4 | tr -d '%')
progress=$(awk -v p="$percent" 'BEGIN { v = p / 100; if (v < 0.01) v = 0.01; printf "%.2f", v }')
"$(dirname "$(readlink -f "$0")")/osd.sh" --custom-icon display-brightness-symbolic --custom-progress "$progress" --custom-progress-text "${percent}%"
