#!/bin/bash

# Toggle microphone mute (and the laptop mic-mute LED when there is one)

source "$(dirname "$(readlink -f "$0")")/common.sh"

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle >/dev/null

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
  led=1 message="Microphone muted" icon="microphone-sensitivity-muted-symbolic"
else
  led=0 message="Microphone on" icon="audio-input-microphone-symbolic"
fi

if [[ -e /sys/class/leds/platform::micmute/brightness ]]; then
  brightnessctl --device="platform::micmute" set "$led" >/dev/null 2>&1 || true
fi

"$SCRIPTS_DIR/osd.sh" --custom-message "$message" --custom-icon "$icon"
