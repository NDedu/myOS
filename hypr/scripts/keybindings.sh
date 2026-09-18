#!/bin/bash

# Searchable list of the keybindings (written by hyprland.lua on every config load)

source "$(dirname "$(readlink -f "$0")")/common.sh"

cache="${XDG_RUNTIME_DIR:-/tmp}/hypr-keybindings.tsv"

if [[ ! -s $cache ]]; then
  notify-send -u low "No keybindings found" "Reload Hyprland (hyprctl reload) to rebuild the list"
  exit 1
fi

awk -F'\t' 'NF == 2 && !seen[$0]++ { printf "%-38s %s\n", $1, $2 }' "$cache" |
  fuzzel --dmenu --width 90 --lines 20 --prompt "Keybindings  " --placeholder "Search keybindings..." >/dev/null
