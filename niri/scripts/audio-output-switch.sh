#!/bin/bash

# Switch to the next audio output, moving playing streams along
# (niri version of ~/.config/hypr/scripts/audio-output-switch.sh, which shows its pop-up through Hyprland)

osd="$(dirname "$(readlink -f "$0")")/osd.sh"

sinks=$(pactl -f json list sinks | jq '[.[] | select((.ports | length == 0) or ([.ports[]? | .availability != "not available"] | any))]')
count=$(jq 'length' <<<"$sinks")

if ((count == 0)); then
  "$osd" --custom-message "No audio devices found"
  exit 1
fi

current=$(pactl get-default-sink)
index=$(jq -r --arg name "$current" 'map(.name) | index($name)' <<<"$sinks")

if [[ $index != "null" ]]; then
  next=$(((index + 1) % count))
else
  next=0
fi

sink=$(jq -c ".[$next]" <<<"$sinks")
name=$(jq -r '.name' <<<"$sink")
description=$(jq -r '.description // .name' <<<"$sink")
volume=$(jq -r '.volume | to_entries[0].value.value_percent | sub("%"; "") | tonumber' <<<"$sink")
muted=$(jq -r '.mute' <<<"$sink")

if [[ $muted == "true" ]] || ((volume == 0)); then
  icon="audio-volume-muted"
elif ((volume <= 33)); then
  icon="audio-volume-low"
elif ((volume <= 66)); then
  icon="audio-volume-medium"
else
  icon="audio-volume-high"
fi

if [[ $name != "$current" ]]; then
  pactl set-default-sink "$name"

  pactl list short sink-inputs | awk '{ print $1 }' | while read -r input; do
    pactl move-sink-input "$input" "$name" 2>/dev/null || true
  done
fi

"$osd" --custom-message "$description" --custom-icon "$icon"
