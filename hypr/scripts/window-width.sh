#!/bin/bash

# Save or restore the focused window's width, per app and workspace
# Usage: window-width.sh save|restore

set -euo pipefail

source "$(dirname "$(readlink -f "$0")")/common.sh"

WIDTHS_DIR="$STATE_DIR/window-widths"

window_width() {
  hyprctl clients -j | jq -er --arg address "$1" '.[] | select(.address == $address) | .size[0]'
}

resize_width_by() {
  hypr_dispatch "hl.dsp.window.resize({ window = \"$1\", x = $2, y = 0, relative = true })"
}

action=${1:-}
[[ $action == "save" || $action == "restore" ]] || {
  echo "Usage: window-width.sh save|restore" >&2
  exit 1
}

active=$(hyprctl activewindow -j)
key=$(jq -r '[.class, .initialClass, .title] | map(select(. != null and . != "")) | first // empty' <<<"$active")
workspace=$(jq -r '.workspace.id // .workspace.name // empty' <<<"$active")
[[ -n $key && -n $workspace ]] || exit 1

filename="workspace-${workspace}-${key//\//_}"
state_file="$WIDTHS_DIR/${filename//$'\n'/_}.width"

if [[ $action == "save" ]]; then
  mkdir -p "$WIDTHS_DIR"
  jq -er '.size[0]' <<<"$active" >"$state_file"
  notify-send -u low "    Saved width for $key on workspace $workspace" "Restore it with Super + Home"
  exit 0
fi

if [[ ! -f $state_file ]]; then
  notify-send -u low "    No saved width for $key on workspace $workspace" "Save one with Super + Alt + Home"
  exit 1
fi

width=$(<"$state_file")
[[ $width =~ ^[0-9]+$ ]] || exit 1

address=$(jq -r '.address // empty' <<<"$active")
window="address:$address"
current_width=$(window_width "$address")
((current_width == width)) && exit 0

# Resizing a tile can move either edge, so probe which direction grows the window first
direction=""
for probe in 10 -10; do
  resize_width_by "$window" "$probe"
  next_width=$(window_width "$address")

  if ((next_width != current_width)); then
    if (((next_width - current_width) * probe > 0)); then
      direction=1
    else
      direction=-1
    fi
    current_width=$next_width
    break
  fi
done

[[ -n $direction ]] || exit 1

for _ in {1..6}; do
  delta=$((width - current_width))
  ((delta == 0)) && break

  resize_width_by "$window" "$((delta * direction))"
  next_width=$(window_width "$address")

  ((next_width == current_width)) && break
  current_width=$next_width
done
