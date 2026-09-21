#!/bin/bash

# Lock the screen with hyprlock (SUPER + CTRL + L)

source "$(dirname "$(readlink -f "$0")")/common.sh"

if ! pidof hyprlock >/dev/null; then
  (
    hyprlock
    "$SCRIPTS_DIR/wake.sh"
  ) >/dev/null 2>&1 &
fi

# Unlock with the first keyboard layout
hyprctl switchxkblayout all 0 >/dev/null 2>&1

# Don't run the screensaver on top of the lock screen
pkill -f '[o]rg.hypr.screensaver' 2>/dev/null

# Turn the displays and keyboard backlight off a minute after locking, so the panel isn't lit
# while away. Any key or mouse movement wakes them (input.lua enables dpms on input), and
# unlocking runs wake.sh above. Skipped when the screen is only being locked before suspend.
if [[ ${LOCK_ONLY:-false} != "true" ]]; then
  (
    sleep 60
    pidof hyprlock >/dev/null || exit 0
    "$SCRIPTS_DIR/brightness-keyboard.sh" off
    "$SCRIPTS_DIR/brightness-display.sh" off
  ) >/dev/null 2>&1 &
fi
