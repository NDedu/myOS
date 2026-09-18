#!/bin/bash

# Do-not-disturb indicator, always shown so it can be clicked either way:
# bright while notifications are silenced, dimmed while they show (the default).
# Works with mako, swaync or dunst.
silenced() {
  if pgrep -x mako >/dev/null; then
    makoctl mode | grep -q 'do-not-disturb'
  elif pgrep -x swaync >/dev/null; then
    [[ $(swaync-client -D) == "true" ]]
  elif pgrep -x dunst >/dev/null; then
    [[ $(dunstctl is-paused) == "true" ]]
  else
    return 1
  fi
}

if silenced; then
  echo '{"text": "󰂛", "tooltip": "Allow Notifications", "class": "active"}'
else
  echo '{"text": "󰂛", "tooltip": "Silence Notifications", "class": "inactive"}'
fi
