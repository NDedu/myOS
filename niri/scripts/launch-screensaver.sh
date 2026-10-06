#!/bin/bash

# Start the screensaver on every monitor in niri: swayidle after 10 minutes when idle is allowed, or the system menu
# (niri version of ~/.config/hypr/scripts/launch-screensaver.sh)

scripts="$(dirname "$(readlink -f "$0")")"

pgrep -f -- '--class=[o]rg.niri.screensaver' >/dev/null && exit 0

screensavers() {
  niri msg --json windows | jq '[.[] | select(.app_id == "org.niri.screensaver")] | length'
}

focused=$(niri msg --json focused-output | jq -r '.name // empty')

# New windows open on the focused monitor, so wait for each one before moving on
for monitor in $(niri msg --json outputs | jq -r 'to_entries[] | select(.value.logical != null) | .key'); do
  niri msg action focus-monitor "$monitor"
  count=$(screensavers)
  setsid ghostty --class=org.niri.screensaver --config-file="$HOME/.config/ghostty/screensaver" --font-size=18 \
    -e "$scripts/screensaver.sh" >/dev/null 2>&1 &
  for _ in {1..50}; do
    (($(screensavers) > count)) && break
    sleep 0.1
  done
done

[[ -n $focused ]] && niri msg action focus-monitor "$focused"
