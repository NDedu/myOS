#!/bin/bash

# swayosd-client on the focused monitor (niri version of ~/.config/hypr/scripts/osd.sh)
# Usage: osd.sh <swayosd-client args...>   e.g. osd.sh --output-volume +10

monitor=$(niri msg --json focused-output 2>/dev/null | jq -r '.name // empty')
exec swayosd-client ${monitor:+--monitor "$monitor"} "$@"
