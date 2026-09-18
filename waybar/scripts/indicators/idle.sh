#!/bin/bash

# Idle indicator (coffee cup), always shown so it can be clicked either way:
# bright while staying awake, dimmed while the idle screensaver and lock are allowed.

if [[ -f $HOME/.local/state/hypr/allow-idle ]] && pgrep -x hypridle >/dev/null; then
  echo '{"text": "󰅶", "tooltip": "Stay Awake", "class": "inactive"}'
else
  echo '{"text": "󰅶", "tooltip": "Allow Idle Lock &amp; Screensaver", "class": "active"}'
fi
