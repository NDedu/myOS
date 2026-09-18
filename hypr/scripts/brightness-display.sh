#!/bin/bash

# Change the laptop display brightness with an OSD, or turn all displays off/on
# Usage: brightness-display.sh +5%|5%-|50%|off|on

source "$(dirname "$(readlink -f "$0")")/common.sh"

step="${1:-+5%}"

if [[ $step == "off" ]]; then
  hypr_dispatch 'hl.dsp.dpms({ action = "disable" })'
  exit 0
elif [[ $step == "on" ]]; then
  # Skip when every display is already lit: a redundant enable right after resume
  # forces a modeset that flashes the unlock screen
  hyprctl monitors -j | jq -e '[.[] | select(.disabled == false)] | length > 0 and all(.dpmsStatus)' >/dev/null 2>&1 && exit 0
  hypr_dispatch 'hl.dsp.dpms({ action = "enable" })'
  exit 0
fi

# Most likely backlight device
device="$(ls -1 /sys/class/backlight 2>/dev/null | head -n1)"
for candidate in amdgpu_bl* intel_backlight acpi_video*; do
  for match in /sys/class/backlight/$candidate; do
    if [[ -e $match ]]; then
      device="${match##*/}"
      break 2
    fi
  done
done

[[ -n $device ]] || exit 1

# Drop overlapping key repeats so concurrent runs don't race
exec {lock_fd}>"${XDG_RUNTIME_DIR:-/tmp}/hypr-brightness-display.lock"
flock -n "$lock_fd" || exit 0

brightness() {
  brightnessctl -d "$device" -m | cut -d',' -f4 | tr -d '%'
}

current=$(brightness)

# 1% steps at or below 5%, and absolute targets so raw backlight rounding doesn't make uneven steps
if [[ $step == "+5%" ]]; then
  ((current < 5)) && target=$((current + 1)) || target=$((current + 5))
  ((target > 100)) && target=100
  step="$target%"
elif [[ $step == "5%-" ]]; then
  ((current <= 5)) && target=$((current - 1)) || target=$((current - 5))
  ((target < 1)) && target=1
  step="$target%"
fi

brightnessctl -d "$device" set "$step" >/dev/null

percent=$(brightness)
progress=$(awk -v p="$percent" 'BEGIN { v = p / 100; if (v < 0.01) v = 0.01; printf "%.2f", v }')
"$SCRIPTS_DIR/osd.sh" --custom-icon display-brightness-symbolic --custom-progress "$progress" --custom-progress-text "${percent}%"
