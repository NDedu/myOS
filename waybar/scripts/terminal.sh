#!/bin/bash

# Open a terminal with the given app-id, optionally running a command
# Usage: terminal.sh <app-id> [command] [args...]
# Uses xdg-terminal-exec when installed, otherwise the first supported terminal found.

app_id=$1
shift

if command -v xdg-terminal-exec >/dev/null; then
  exec xdg-terminal-exec --app-id="$app_id" ${1:+-e} "$@"
fi

for terminal in $TERMINAL alacritty kitty foot ghostty; do
  command -v "$terminal" >/dev/null || continue

  case $(basename "$terminal") in
  alacritty) exec alacritty --class "$app_id" ${1:+-e} "$@" ;;
  kitty) exec kitty --class "$app_id" "$@" ;;
  foot) exec foot --app-id "$app_id" "$@" ;;
  ghostty) exec ghostty --class="$app_id" ${1:+-e} "$@" ;;
  esac
done

notify-send -u critical "No terminal found" "Install ghostty (or alacritty, kitty, foot)"
exit 1
