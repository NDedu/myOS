#!/bin/bash

# Pop the active window out (float, resize, center, pin), or put a popped window back
# Usage: window-pop.sh [width height [x y]]

source "$(dirname "$(readlink -f "$0")")/common.sh"

width=${1:-1300}
height=${2:-900}
x=${3:-}
y=${4:-}

active=$(hyprctl activewindow -j)
address=$(jq -r '.address // empty' <<<"$active")
[[ -n $address ]] || exit 0
window="address:$address"

if [[ $(jq -r '.pinned' <<<"$active") == "true" ]]; then
  hypr_dispatch "hl.dsp.window.pin({ window = \"$window\" })"
  hypr_dispatch "hl.dsp.window.float({ window = \"$window\", action = \"toggle\" })"
  hypr_dispatch "hl.dsp.window.tag({ window = \"$window\", tag = \"-pop\" })"
else
  hypr_dispatch "hl.dsp.window.float({ window = \"$window\", action = \"toggle\" })"
  hypr_dispatch "hl.dsp.window.resize({ window = \"$window\", x = $width, y = $height })"

  if [[ -n $x && -n $y ]]; then
    hypr_dispatch "hl.dsp.window.move({ window = \"$window\", x = $x, y = $y })"
  else
    hypr_dispatch "hl.dsp.window.center({ window = \"$window\" })"
  fi

  hypr_dispatch "hl.dsp.window.pin({ window = \"$window\" })"
  hypr_dispatch "hl.dsp.window.alter_zorder({ window = \"$window\", mode = \"top\" })"
  hypr_dispatch "hl.dsp.window.tag({ window = \"$window\", tag = \"+pop\" })"
fi
