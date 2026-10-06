#!/bin/bash

# Focus the terminal window already running a TUI, or launch it in a new one
# (niri version of ~/.config/waybar/scripts/launch-or-focus-tui.sh, for the bar's clicks)
# Usage: launch-or-focus-tui.sh <command> [args...]

if (($# == 0)); then
  echo "Usage: launch-or-focus-tui.sh <command> [args...]"
  exit 1
fi

app_id="org.waybar.$(basename "$1")"
id=$(niri msg --json windows | jq -r --arg id "$app_id" 'first(.[] | select(.app_id == $id) | .id) // empty')

if [[ -n $id ]]; then
  niri msg action focus-window --id "$id"
else
  exec setsid "$HOME/.config/waybar/scripts/terminal.sh" "$app_id" "$@"
fi
