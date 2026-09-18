#!/bin/bash

# Focus the terminal window already running a TUI, or launch it in a new one
# Usage: launch-or-focus-tui.sh <command> [args...]

source "$(dirname "$(readlink -f "$0")")/common.sh"

if (($# == 0)); then
  echo "Usage: launch-or-focus-tui.sh <command> [args...]"
  exit 1
fi

app_id="org.waybar.$(basename "$1")"
window_address=$(hyprctl clients -j | jq -r --arg id "$app_id" '.[] | select(.class == $id) | .address' | head -n1)

if [[ -n $window_address ]]; then
  # Lua config syntax first (Hyprland 0.55+), then the old hyprlang dispatcher
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$window_address\" })" >/dev/null 2>&1 ||
    hyprctl dispatch focuswindow "address:$window_address"
else
  exec setsid "${APP[@]}" "$SCRIPTS_DIR/terminal.sh" "$app_id" "$@"
fi
