#!/bin/bash

# The bar in niri: waybar with ../waybar.jsonc (the Hyprland bar with niri's workspaces) and ../waybar.css.
# ~/.config/waybar/scripts/restart-waybar.sh would start the Hyprland bar instead.
# Usage: waybar.sh [restart|toggle]   (restart is what niri runs at startup)

niri_dir="$(dirname "$(dirname "$(readlink -f "$0")")")"

if pgrep -x waybar >/dev/null; then
  pkill -9 -x waybar
  [[ ${1:-restart} == "toggle" ]] && exit 0
fi

setsid waybar -c "$niri_dir/waybar.jsonc" -s "$niri_dir/waybar.css" >/dev/null 2>&1 &
