#!/bin/bash

# Show, set or step the focused monitor's scale (Super + / and Super + Alt + /). The new scale is remembered for
# that monitor in ~/.local/state/niri/output-scales.kdl, which ../config.kdl includes, so it also applies at every
# login (niri version of ~/.config/hypr/scripts/monitor-scaling.sh)
# Usage: display-scale.sh [up|down|SCALE]

SCALES=(1 1.25 1.33333 1.6 2 3 4)
SCALES_FILE="$HOME/.local/state/niri/output-scales.kdl"

# The same steps as in Hyprland, which only accepts scales where the mode divides into whole logical pixels
# (in 1/120 steps), so the requested scale is rounded up to the nearest clean value
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

output=$(niri msg --json focused-output | jq -ec 'select(.name != null)') || exit 1
name=$(jq -r '.name' <<<"$output")
make=$(jq -r '.make' <<<"$output")
model=$(jq -r '.model' <<<"$output")
serial=$(jq -r '.serial // "Unknown"' <<<"$output")
current=$(jq -r '.logical.scale' <<<"$output")
width=$(jq -r '.modes[.current_mode].width' <<<"$output")
height=$(jq -r '.modes[.current_mode].height' <<<"$output")

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
    echo "Usage: display-scale.sh [up|down|SCALE]" >&2
    exit 1
  fi
  ;;
esac

niri msg output "$name" scale "$scale" >/dev/null

# Keyed by make, model and serial so the scale follows the monitor to any port; the connector name when
# niri doesn't know them. The key goes into a KDL string, so no quotes or backslashes
key="$make $model $serial"
if [[ $make == Unknown || $model == Unknown || $key == *[\"\\[:cntrl:]]* ]]; then
  key=$name
fi

# One line per monitor; this one's line is replaced
[[ $scale == *.* ]] || scale="$scale.0"
mkdir -p "$(dirname "$SCALES_FILE")"
{
  [[ -f $SCALES_FILE ]] && key=$key awk 'index($0, "output \"" ENVIRON["key"] "\" ") != 1' "$SCALES_FILE"
  printf 'output "%s" { scale %s; }\n' "$key" "$scale"
} >"$SCALES_FILE.tmp" && mv "$SCALES_FILE.tmp" "$SCALES_FILE"

notify-send -u low "󰍹    Scale ${scale%.0} on $name"
