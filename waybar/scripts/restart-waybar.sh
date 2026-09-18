#!/bin/bash

# Restart Waybar

source "$(dirname "$(readlink -f "$0")")/common.sh"

pkill -9 -x waybar
setsid "${APP[@]}" waybar >/dev/null 2>&1 &
