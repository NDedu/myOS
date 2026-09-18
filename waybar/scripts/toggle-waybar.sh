#!/bin/bash

# Toggle Waybar visibility

source "$(dirname "$(readlink -f "$0")")/common.sh"

if pgrep -x waybar >/dev/null; then
  pkill -9 -x waybar
else
  setsid "${APP[@]}" waybar >/dev/null 2>&1 &
fi
