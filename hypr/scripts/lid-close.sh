#!/bin/bash

# Lid closed: with an external monitor, turn the laptop display off (clamshell mode).

source "$(dirname "$(readlink -f "$0")")/common.sh"

external_connected() {
  for status in /sys/class/drm/card*-*/status; do
    [[ $status =~ -(eDP|LVDS|DSI)-[^/]+/status$ ]] && continue
    [[ $(<"$status") == "connected" ]] && return 0
  done
  return 1
}

if external_connected; then
  "$SCRIPTS_DIR/monitor-internal.sh" off
# Without an external monitor, logind suspends and hypridle locks before sleep.
# If lid close is ever set not to suspend (HandleLidSwitch=ignore), lock here instead:
# else
#   LOCK_ONLY=true "$SCRIPTS_DIR/lock.sh"
fi
