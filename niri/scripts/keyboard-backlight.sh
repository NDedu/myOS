#!/bin/bash

# Keyboard backlight keys in niri: step up or down, or cycle, with the pop-up (niri version of the key
# part of ~/.config/hypr/scripts/brightness-keyboard.sh; its off/restore, used around locking, works as it is)
# Usage: keyboard-backlight.sh up|down|cycle

direction="${1:-up}"

device=""
for candidate in /sys/class/leds/*kbd_backlight*; do
  if [[ -e $candidate ]]; then
    device="$(basename "$candidate")"
    break
  fi
done

if [[ -z $device ]]; then
  echo "No keyboard backlight device found" >&2
  exit 1
fi

max=$(brightnessctl -d "$device" max)
current=$(brightnessctl -d "$device" get)

# 10% of max per step; keyboards with only a few levels fall back to 1
step=$((max / 10))
((step < 1)) && step=1

case "$direction" in
cycle)
  new=$((current + step))
  ((new > max)) && new=0
  ;;
up)
  new=$((current + step))
  ((new > max)) && new=$max
  ;;
*)
  new=$((current - step))
  ((new < 0)) && new=0
  ;;
esac

brightnessctl -d "$device" set "$new" >/dev/null

percent=$((new * 100 / max))
progress=$(awk -v p="$percent" 'BEGIN { v = p / 100; if (v < 0.01) v = 0.01; printf "%.2f", v }')
"$(dirname "$(readlink -f "$0")")/osd.sh" --custom-icon keyboard-brightness-symbolic --custom-progress "$progress" --custom-progress-text "${percent}%"
