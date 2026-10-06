#!/bin/bash

# Stay awake (the default) or allow idle in niri: the bar's coffee cup and Toggle > Idle Lock in the menu.
# The same setting as in Hyprland (~/.local/state/hypr/allow-idle), read by ~/.config/swayidle/config.
# ~/.config/waybar/scripts/toggle-idle.sh would start hypridle instead.
# Usage: idle.sh [toggle|status]   (status prints the bar icon)

ALLOW_IDLE="$HOME/.local/state/hypr/allow-idle"

# Bright while staying awake, dimmed while idle is allowed, as in Hyprland
if [[ ${1:-toggle} == "status" ]]; then
  if [[ -f $ALLOW_IDLE ]] && pgrep -x swayidle >/dev/null; then
    echo '{"text": "󰅶", "tooltip": "Stay Awake", "class": "inactive"}'
  else
    echo '{"text": "󰅶", "tooltip": "Allow Idle Lock &amp; Screensaver", "class": "active"}'
  fi
  exit 0
fi

if [[ -f $ALLOW_IDLE ]]; then
  rm -f "$ALLOW_IDLE"
  notify-send -u low "󰅶    Stay awake" "No screensaver or lock when idle"
else
  mkdir -p "$(dirname "$ALLOW_IDLE")"
  touch "$ALLOW_IDLE"
  notify-send -u low "󱫖    Idle lock and screensaver allowed" "Screensaver after 10 minutes, lock after 15"
fi

# The timeouts need swayidle running
if ! pgrep -x swayidle >/dev/null; then
  setsid swayidle -w >/dev/null 2>&1 &
fi

pkill -RTMIN+9 waybar
