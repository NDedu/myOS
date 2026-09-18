#!/bin/bash

# Enable, disable or toggle the laptop display (disabling needs another active monitor)
# Usage: monitor-internal.sh on|off|toggle|recover

source "$(dirname "$(readlink -f "$0")")/common.sh"

FLAG="$STATE_DIR/toggles/internal-monitor-disable.lua"
MIRROR_FLAG="$STATE_DIR/toggles/internal-monitor-mirror.lua"

internal=$(hyprctl monitors all -j | jq -r '.[] | select(.name | test("^(eDP|LVDS|DSI)-")) | .name' | head -n1)

external_active() {
  hyprctl monitors -j | jq -e 'any(.[]; (.name | test("^(eDP|LVDS|DSI)-") | not) and .disabled == false)' >/dev/null
}

on() {
  if [[ -f $FLAG ]]; then
    rm -f "$FLAG"
    hyprctl reload >/dev/null
    notify-send -u low "󰍹    Laptop display enabled"
  fi

  hypr_dispatch 'hl.dsp.dpms({ action = "enable" })'
}

off() {
  if [[ -z $internal ]]; then
    notify-send -u low "󰍹    No laptop display found"
    exit 1
  fi

  # The name is written into Lua that gets loaded, so only a plain connector name may pass
  if [[ ! $internal =~ ^[A-Za-z0-9._-]+$ ]]; then
    notify-send -u low "󰍹    Refusing unsafe monitor name"
    exit 1
  fi

  if ! external_active; then
    notify-send -u low "󰍹    Can't disable the only active display"
    exit 1
  fi

  if [[ ! -f $FLAG && ! -f $MIRROR_FLAG ]]; then
    mkdir -p "$(dirname "$FLAG")"
    printf 'hl.monitor({ output = "%s", disabled = true })\n' "$internal" >"$FLAG"
    hyprctl reload >/dev/null
    notify-send -u low "󰍹    Laptop display disabled"
  fi
}

case "$1" in
on) on ;;
off) off ;;
toggle) if [[ -f $FLAG ]]; then on; else off; fi ;;
# Called when a monitor is unplugged: never leave the laptop without a display
recover) [[ -f $FLAG ]] && ! external_active && on ;;
*)
  echo "Usage: monitor-internal.sh on|off|toggle|recover" >&2
  exit 1
  ;;
esac
