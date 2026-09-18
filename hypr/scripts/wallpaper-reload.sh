#!/bin/bash

# The desktop wallpaper: started at login (modules/autostart.lua runs this with --quiet), and reloaded after
# the image is replaced, since swaybg only reads it when it starts. The new swaybg starts before the old one
# closes, so the desktop never goes blank.
# Usage: wallpaper-reload.sh [--quiet]

source "$(dirname "$(readlink -f "$0")")/common.sh"

# Wallpaper settings: the only place to edit when the image or its format changes (jpg, jpeg, png, webp)
WALLPAPER="$HYPR_DIR/wallpaper.jpeg"
# How it covers the screen: fill (crop to cover), fit (whole image, with bars), stretch, center or tile
MODE="fill"

if [[ ! -f $WALLPAPER ]]; then
  notify-send -u critical "Wallpaper not found" "No $WALLPAPER (set it at the top of ${BASH_SOURCE[0]})"
  exit 1
fi

old=$(pgrep -x swaybg)

setsid "${APP[@]}" swaybg -i "$WALLPAPER" -m "$MODE" >/dev/null 2>&1 &

# Wait for the new swaybg (up to 3 s), then give it a moment to draw before closing the old one
for _ in {1..30}; do
  pgrep -x swaybg | grep -qvxF "${old:-none}" && break
  sleep 0.1
done

if [[ -n $old ]]; then
  sleep 1
  kill $old 2>/dev/null
fi

[[ ${1:-} == "--quiet" ]] || notify-send -u low "Wallpaper reloaded"
