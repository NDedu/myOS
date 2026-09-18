#!/bin/bash

# Warn once when the battery drops to 10% while discharging.
# Run every minute by ~/.config/systemd/user/battery-monitor.timer.

THRESHOLD=10
FLAG="${XDG_RUNTIME_DIR:-/run/user/$UID}/battery-low-notified"

# battery_BAT* is the system battery; peripherals show up as battery_hidpp_*, battery_ps_* etc.
battery=$(upower -e | grep -m1 "/battery_BAT") || exit 0
info=$(upower -i "$battery")
level=$(awk '/percentage/ { gsub("%", "", $2); print int($2); exit }' <<<"$info")
state=$(awk '/state/ { print $2; exit }' <<<"$info")

[[ $level =~ ^[0-9]+$ ]] || exit 0

if [[ $state == "discharging" ]] && ((level <= THRESHOLD)); then
  if [[ ! -f $FLAG ]]; then
    # Only remember it once the notification actually went out: the timer can fire
    # before the session bus is up, and a lost warning must be retried.
    notify-send -u critical "󱐋    Time to recharge!" "Battery is down to ${level}%" -i battery-caution -t 30000 &&
      touch "$FLAG"
  fi
else
  rm -f "$FLAG"
fi
