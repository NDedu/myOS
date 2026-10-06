#!/bin/bash

# Night light in niri with wlsunset (hyprsunset only works in Hyprland): the screen at 4000K while on,
# like Hyprland's, and off at every login. The bar's moon and Toggle > Nightlight in the menu.
# Usage: nightlight.sh [toggle|status]   (status prints the bar icon)

# Bright while on, dimmed while off, as in Hyprland
if [[ ${1:-toggle} == "status" ]]; then
  if pgrep -x wlsunset >/dev/null; then
    echo '{"text": "󰔎", "tooltip": "Day Light", "class": "active"}'
  else
    echo '{"text": "󰔎", "tooltip": "Night Light", "class": "inactive"}'
  fi
  exit 0
fi

if pgrep -x wlsunset >/dev/null; then
  pkill -x wlsunset
  notify-send -u low "    Daylight screen temperature"
else
  # wlsunset follows the sun; with day and night 1K apart and fixed times it just stays at 4000K
  setsid wlsunset -t 4000 -T 4001 -S 06:00 -s 18:00 >/dev/null 2>&1 &
  notify-send -u low "    Nightlight screen temperature"
fi

# Update the night light icon in the bar
pkill -RTMIN+12 waybar 2>/dev/null || true
