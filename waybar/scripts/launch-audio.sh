#!/bin/bash

# Launch the audio controls: wiremix TUI, falling back to pavucontrol

source "$(dirname "$(readlink -f "$0")")/common.sh"

if command -v wiremix >/dev/null; then
  exec "$SCRIPTS_DIR/launch-or-focus-tui.sh" wiremix
elif command -v pavucontrol >/dev/null; then
  exec setsid "${APP[@]}" pavucontrol
else
  notify-send -u low "No audio controls found" "Install wiremix or pavucontrol"
fi
