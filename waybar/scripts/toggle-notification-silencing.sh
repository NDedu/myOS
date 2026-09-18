#!/bin/bash

# Toggle notification do-not-disturb mode (mako, swaync or dunst)

if pgrep -x mako >/dev/null; then
  makoctl mode -t do-not-disturb
elif pgrep -x swaync >/dev/null; then
  swaync-client -d -sw >/dev/null
elif pgrep -x dunst >/dev/null; then
  dunstctl set-paused toggle
else
  notify-send -u low "No supported notification daemon running (mako, swaync or dunst)"
  exit 1
fi

if "$(dirname "$(readlink -f "$0")")/indicators/notification-silencing.sh" | grep -q '"class": "active"'; then
  # Dunst holds notifications back while paused, so only announce it on the others
  pgrep -x dunst >/dev/null || notify-send -u low "󰂛    Silenced notifications"
else
  notify-send -u low "󰂚    Enabled notifications"
fi

pkill -RTMIN+10 waybar
