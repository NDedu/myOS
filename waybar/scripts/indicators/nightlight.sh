#!/bin/bash

# Night light indicator, always shown so it can be clicked either way:
# bright while the warm night light is on, dimmed while the screen has its normal colors.
# hyprsunset only runs once night light has been used, so no hyprsunset means it's off.

temperature=""
if pgrep -x hyprsunset >/dev/null; then
  temperature=$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+' | head -n1)
fi

if [[ -n $temperature ]] && ((temperature < 6000)); then
  echo '{"text": "󰔎", "tooltip": "Day Light", "class": "active"}'
else
  echo '{"text": "󰔎", "tooltip": "Night Light", "class": "inactive"}'
fi
