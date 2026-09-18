#!/bin/bash

# Toggle nightlight (warm screen temperature) with hyprsunset

ON_TEMP=4000
OFF_TEMP=6500

source "$(dirname "$(readlink -f "$0")")/common.sh"

current_temp() {
  hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+' | head -n1
}

if ! pgrep -x hyprsunset >/dev/null; then
  setsid "${APP[@]}" hyprsunset >/dev/null 2>&1 &
  sleep 1
fi

current=$(current_temp)

if [[ -z $current ]] || ((current >= 6000)); then
  target=$ON_TEMP
  message="    Nightlight screen temperature"
else
  target=$OFF_TEMP
  message="    Daylight screen temperature"
fi

# A freshly started hyprsunset applies its profile at the end of its boot,
# overriding anything set before then, so resend until it sticks
for _ in {1..10}; do
  hyprctl hyprsunset temperature "$target" >/dev/null 2>&1
  sleep 0.2
  [[ $(current_temp) == "$target" ]] && break
done

notify-send -u low "$message"

# Update the night light icon in the bar
pkill -RTMIN+12 waybar 2>/dev/null || true
