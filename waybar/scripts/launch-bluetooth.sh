#!/bin/bash

# Launch the bluetooth controls: bluetui TUI, falling back to blueman

source "$(dirname "$(readlink -f "$0")")/common.sh"

rfkill unblock bluetooth

if command -v bluetui >/dev/null; then
  exec "$SCRIPTS_DIR/launch-or-focus-tui.sh" bluetui
elif command -v blueman-manager >/dev/null; then
  exec setsid "${APP[@]}" blueman-manager
else
  notify-send -u low "No bluetooth controls found" "Install bluetui or blueman"
fi
