#!/bin/bash

# Clipboard history (cliphist, recorded from autostart) in fuzzel; the pick goes back on the clipboard

source "$(dirname "$(readlink -f "$0")")/common.sh"

if ! command -v cliphist >/dev/null; then
  notify-send -u low "Clipboard history unavailable" "Install cliphist"
  exit 1
fi

selection=$(cliphist list | fuzzel --dmenu --width 80 --lines 12 --prompt "Clipboard  ") || exit 0
[[ -n $selection ]] && cliphist decode <<<"$selection" | wl-copy
