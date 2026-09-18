#!/bin/bash

# Pick a power profile (needs power-profiles-daemon)

source "$(dirname "$(readlink -f "$0")")/common.sh"

if ! command -v powerprofilesctl >/dev/null; then
  notify-send -u low "Power profiles unavailable" "Install power-profiles-daemon"
  exit 1
fi

# An icon per profile, prefixed for the picker and stripped again before setting.
# Profile names never contain spaces, so the name is whatever follows the last one.
icon_for() {
  case $1 in
  performance) echo "󰉁" ;;
  balanced) echo "󰗑" ;;
  power-saver) echo "󰌪" ;;
  *) echo "󰁹" ;;
  esac
}

profiles=$(powerprofilesctl list | awk '/^\s*[* ]\s*[a-zA-Z0-9\-]+:$/ { gsub(/^[*[:space:]]+|:$/,""); print }' | tac)

labeled=$(while read -r name; do
  [[ -n $name ]] && printf '%s    %s\n' "$(icon_for "$name")" "$name"
done <<<"$profiles")

choice=$(echo "$labeled" | "$SCRIPTS_DIR/launcher.sh" --dmenu "Power Profile ($(powerprofilesctl get))")
profile=${choice##* }

if [[ -n $profile && $profile != "CNCLD" ]]; then
  powerprofilesctl set "$profile"
fi
