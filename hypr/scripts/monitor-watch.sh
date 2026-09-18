#!/bin/bash

# Watch Hyprland monitor events: when a monitor is unplugged, re-enable the laptop
# display and drop mirroring so the screen never stays black. Started from autostart.

source "$(dirname "$(readlink -f "$0")")/common.sh"

# Also recover a disabled laptop display left over from the last session
"$SCRIPTS_DIR/monitor-internal.sh" recover
"$SCRIPTS_DIR/monitor-mirror.sh" recover

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r event; do
  case "$event" in
  monitorremoved\>\>* | monitorremovedv2\>\>*)
    sleep 1
    "$SCRIPTS_DIR/monitor-internal.sh" recover
    "$SCRIPTS_DIR/monitor-mirror.sh" recover
    ;;
  esac
done
