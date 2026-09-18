#!/bin/bash

# App launcher, or a dmenu-style picker when called with --dmenu (options on stdin, selection on stdout)
# Usage: launcher.sh
#        echo -e "a\nb" | launcher.sh --dmenu "Prompt"
# Uses fuzzel (styled in ~/.config/fuzzel/fuzzel.ini), falling back to wofi or rofi.

source "$(dirname "$(readlink -f "$0")")/common.sh"

if [[ $1 == "--dmenu" ]]; then
  prompt=${2:-Select}
fi

if command -v fuzzel >/dev/null; then
  # A second press closes the launcher instead of opening another one
  pkill -x fuzzel && exit 0

  if [[ -n $prompt ]]; then
    exec fuzzel --dmenu --minimal-lines --width 36 --prompt "$prompt  " --placeholder ""
  else
    # Apps start through uwsm when the session uses it, so each gets its own systemd scope
    # instead of running inside Hyprland's unit
    exec fuzzel ${APP:+"--launch-prefix=${APP[*]}"}
  fi
elif command -v wofi >/dev/null; then
  if [[ -n $prompt ]]; then exec wofi --dmenu -p "$prompt"; else exec wofi --show drun; fi
elif command -v rofi >/dev/null; then
  if [[ -n $prompt ]]; then exec rofi -dmenu -p "$prompt"; else exec rofi -show drun; fi
fi

notify-send -u critical "No launcher found" "Install fuzzel"
exit 1
