#!/bin/bash

# Show, set or step the focused monitor's scale; the new scale is saved to modules/monitors.lua
# Usage: monitor-scaling.sh [up|down|SCALE]

source "$(dirname "$(readlink -f "$0")")/common.sh"

SCALES=(1 1.25 1.33333 1.6 2 3 4)
MONITORS_LUA="$HYPR_DIR/modules/monitors.lua"

# Hyprland only accepts scales where the mode divides into whole logical pixels
# (in 1/120 steps), so round the requested scale up to the nearest clean value.
clean_scale() {
  awk -v scale="$1" -v width="$2" -v height="$3" '
    function gcd(a, b, t) { while (b) { t = a % b; a = b; b = t } return a }
    BEGIN {
      g = gcd(width * 120, height * 120)
      k = int(scale * 120 + 0.5)
      if (k > g) k = g
      while (g % k != 0) k++
      printf "%g\n", k / 120
    }'
}

# Next or previous distinct clean scale from the SCALES presets
step_scale() {
  local direction=$1 current=$2 width=$3 height=$4 preset clean
  local -a cleans=()

  for preset in "${SCALES[@]}"; do
    clean=$(clean_scale "$preset" "$width" "$height")
    [[ " ${cleans[*]} " == *" $clean "* ]] || cleans+=("$clean")
  done

  printf '%s\n' "${cleans[@]}" | sort -g | awk -v current="$current" -v direction="$direction" '
    { scales[NR] = $1 }
    END {
      best = 1; best_diff = 1e9
      for (i = 1; i <= NR; i++) {
        diff = current - scales[i]; if (diff < 0) diff = -diff
        if (diff < best_diff) { best_diff = diff; best = i }
      }
      if (direction == "up") i = (best < NR) ? best + 1 : NR
      else i = (best > 1) ? best - 1 : 1
      print scales[i]
    }'
}

monitor=$(hyprctl monitors -j | jq -ec '.[] | select(.focused == true)') || exit 1
name=$(jq -r '.name' <<<"$monitor")
current=$(jq -r '.scale' <<<"$monitor")
width=$(jq -r '.width' <<<"$monitor")
height=$(jq -r '.height' <<<"$monitor")
refresh=$(jq -r '.refreshRate' <<<"$monitor")

case "${1:-}" in
"")
  printf '%g\n' "$current"
  exit 0
  ;;
up | down)
  scale=$(step_scale "$1" "$current" "$width" "$height")
  ;;
*)
  if [[ $1 =~ ^[0-9]+([.][0-9]+)?$ ]] && awk -v s="$1" 'BEGIN { exit !(s >= 1 && s <= 4) }'; then
    scale=$(clean_scale "$1" "$width" "$height")
  else
    echo "Usage: monitor-scaling.sh [up|down|SCALE]" >&2
    exit 1
  fi
  ;;
esac

# The name goes into a Lua string, so only a plain connector name may pass
[[ $name =~ ^[A-Za-z0-9._-]+$ ]] || exit 1

hyprctl eval "hl.monitor({ output = \"$name\", mode = \"${width}x${height}@${refresh}\", position = \"auto\", scale = $scale })" >/dev/null

# GTK only honors whole GDK_SCALE values
gdk_scale=$(awk -v s="$scale" 'BEGIN { printf "%d", int(s + 0.5) }')

if [[ -f $MONITORS_LUA ]]; then
  sed -i -E \
    -e "s|^local monitor_scale = .*|local monitor_scale = $scale|" \
    -e "s|^local gdk_scale = .*|local gdk_scale = $gdk_scale|" \
    "$(readlink -f "$MONITORS_LUA")"
fi

notify-send -u low "󰍹    Scale $scale on $name"
