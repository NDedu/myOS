#!/bin/bash

# Toggle between "stay awake" (default) and allowing the idle screensaver and lock.
# The listeners in ~/.config/hypr/hypridle.conf only act while ~/.local/state/hypr/allow-idle exists.

source "$(dirname "$(readlink -f "$0")")/common.sh"

ALLOW_IDLE="$HOME/.local/state/hypr/allow-idle"

if [[ -f $ALLOW_IDLE ]]; then
  rm -f "$ALLOW_IDLE"
  notify-send -u low "󰅶    Stay awake" "No screensaver or lock when idle"
else
  mkdir -p "$(dirname "$ALLOW_IDLE")"
  touch "$ALLOW_IDLE"
  notify-send -u low "󱫖    Idle lock and screensaver allowed" "Screensaver after 10 minutes, lock after 15"
fi

# The listeners need hypridle running
if ! pgrep -x hypridle >/dev/null; then
  setsid "${APP[@]}" hypridle >/dev/null 2>&1 &
fi

pkill -RTMIN+9 waybar
