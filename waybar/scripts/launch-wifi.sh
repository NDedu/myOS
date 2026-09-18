#!/bin/bash

# Launch the network controls: nmtui (NetworkManager) in a floating terminal, falling back to impala (iwd)

source "$(dirname "$(readlink -f "$0")")/common.sh"

rfkill unblock wifi

if command -v nmtui >/dev/null; then
  exec "$SCRIPTS_DIR/launch-or-focus-tui.sh" nmtui
elif command -v impala >/dev/null; then
  exec "$SCRIPTS_DIR/launch-or-focus-tui.sh" impala
else
  notify-send -u low "No network controls found" "Install networkmanager (nmtui)"
fi
