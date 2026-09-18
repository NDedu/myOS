#!/bin/bash

# Mirror the laptop display to the first external monitor, or go back to extended mode
# Usage: monitor-mirror.sh on|off|toggle|recover

source "$(dirname "$(readlink -f "$0")")/common.sh"

FLAG="$STATE_DIR/toggles/internal-monitor-mirror.lua"
DISABLE_FLAG="$STATE_DIR/toggles/internal-monitor-disable.lua"

internal=$(hyprctl monitors all -j | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)-")) | .name' | head -n1)
external=$(hyprctl monitors -j | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)-") | not) | .name' | head -n1)

on() {
  if [[ -z $external ]]; then
    notify-send -u low "󰍹    No external monitor found to mirror to"
    exit 1
  fi

  if [[ -z $internal ]]; then
    notify-send -u low "󰍹    No laptop display found to mirror"
    exit 1
  fi

  # Both names are written into Lua that gets loaded, so only plain connector names may pass
  for output in "$internal" "$external"; do
    if [[ ! $output =~ ^[A-Za-z0-9._-]+$ ]]; then
      notify-send -u low "󰍹    Refusing unsafe monitor name"
      exit 1
    fi
  done

  rm -f "$DISABLE_FLAG"
  mkdir -p "$(dirname "$FLAG")"
  printf 'hl.monitor({ output = "%s", mode = "preferred", position = "auto", scale = 1, mirror = "%s" })\n' "$external" "$internal" >"$FLAG"
  hyprctl reload >/dev/null
  notify-send -u low "󰍹    Mirroring enabled ($external)"
}

off() {
  if [[ -f $FLAG ]]; then
    rm -f "$FLAG"
    hyprctl reload >/dev/null
    notify-send -u low "󰍹    Extended mode restored"
  fi
}

case "$1" in
on) on ;;
off) off ;;
toggle) if [[ -f $FLAG ]]; then off; else on; fi ;;
recover) [[ -f $FLAG && -z $external ]] && off ;;
*)
  echo "Usage: monitor-mirror.sh on|off|toggle|recover" >&2
  exit 1
  ;;
esac
