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

# Turn the displays and keyboard backlight off 3 seconds after locking. Commented out so the
# screen stays on while locked; uncomment to bring it back (LOCK_ONLY=true skips it).
# if [[ ${LOCK_ONLY:-false} != "true" ]]; then
#   (
#     sleep 3
#     pidof hyprlock >/dev/null || exit 0
#     "$SCRIPTS_DIR/brightness-keyboard.sh" off
#     "$SCRIPTS_DIR/brightness-display.sh" off
#   ) >/dev/null 2>&1 &
# fi
