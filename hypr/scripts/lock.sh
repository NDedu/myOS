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

# Don't run the screensaver on top of the lock screen. Its closing animation is turned off first,
# or it waits behind the lock and plays when the screen is unlocked
for address in $(hyprctl clients -j | jq -r '.[] | select(.class == "org.hypr.screensaver") | .address'); do
  hypr_dispatch "hl.dsp.window.set_prop({ window = \"address:$address\", prop = \"no_anim\", value = \"1\" })"
done
pkill -f '[o]rg.hypr.screensaver' 2>/dev/null

# Turn the displays and keyboard backlight off five minutes after locking, so the panel isn't lit
# while away. Any key or mouse movement wakes them (input.lua enables dpms on input), and
# unlocking runs wake.sh above. Skipped when the screen is only being locked before suspend.
# Tied to this lock's hyprlock: unlocking and locking again starts a fresh five minutes.
if [[ ${LOCK_ONLY:-false} != "true" ]]; then
  (
    sleep 1
    lock_pid=$(pidof hyprlock) || exit 0
    sleep 299
    [[ $(pidof hyprlock) == "$lock_pid" ]] || exit 0
    "$SCRIPTS_DIR/brightness-keyboard.sh" off
    "$SCRIPTS_DIR/brightness-display.sh" off
  ) >/dev/null 2>&1 &
fi
