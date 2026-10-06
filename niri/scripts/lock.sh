#!/bin/bash

# Lock the screen in niri with hyprlock, the same lock screen as Hyprland (~/.config/hypr/hyprlock.conf), or
# swaylock (~/.config/swaylock/config) when hyprlock is missing or doesn't start. Super + Ctrl + L, the system
# menu, and swayidle: idle, before suspend, loginctl lock-session (niri version of ~/.config/hypr/scripts/lock.sh)

# The screensaver closes first, so it isn't left waiting behind the lock
pkill -f -- '--class=[o]rg.niri.screensaver' 2>/dev/null

pidof hyprlock swaylock >/dev/null && exit 0

# Returns once hyprlock has had a second to lock: swayidle -w holds a suspend until then
if command -v hyprlock >/dev/null; then
  setsid hyprlock >/dev/null 2>&1 &
  sleep 1
  pidof hyprlock >/dev/null && exit 0
fi

# swaylock returns once the screen is locked (daemonize in its config)
swaylock
