#!/bin/bash

# Enable, disable or toggle the touchpad (stays disabled across reloads)
# Usage: toggle-touchpad.sh [on|off|toggle]

source "$(dirname "$(readlink -f "$0")")/common.sh"

NAME_FILE="$STATE_DIR/touchpad-disabled-name"

device=$(hyprctl devices -j | jq -r '[.mice[] | .name | select(test("touchpad|trackpad"; "i"))] | first // empty')

apply() {
  if [[ -z $device || $device == *[[:cntrl:]]* ]]; then
    echo "No usable touchpad found" >&2
    exit 1
  fi

  local quoted=${device//\\/\\\\}
  quoted=${quoted//\"/\\\"}
  hyprctl eval "hl.device({ name = \"$quoted\", enabled = $1 })" >/dev/null
}

enable() {
  rm -f "$NAME_FILE"
  apply true
  "$SCRIPTS_DIR/osd.sh" --custom-message "Touchpad enabled" --custom-icon input-touchpad-symbolic
}

disable() {
  apply false
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$device" >"$NAME_FILE"
  "$SCRIPTS_DIR/osd.sh" --custom-message "Touchpad disabled" --custom-icon touchpad-disabled-symbolic
}

case "${1:-toggle}" in
on) enable ;;
off) disable ;;
toggle) if [[ -f $NAME_FILE ]]; then enable; else disable; fi ;;
*)
  echo "Usage: toggle-touchpad.sh [on|off|toggle]" >&2
  exit 1
  ;;
esac
