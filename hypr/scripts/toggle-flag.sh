#!/bin/bash

# Turn a config flag from ../toggles/ on or off (it is loaded last by modules/toggles.lua)
# Usage: toggle-flag.sh <window-no-gaps|single-window-aspect-ratio> [on|off|toggle]

source "$(dirname "$(readlink -f "$0")")/common.sh"

flag=$1
source_file="$HYPR_DIR/toggles/$flag.lua"
flag_file="$STATE_DIR/toggles/$flag.lua"

if [[ ! -f $source_file ]]; then
  echo "Unknown flag: $flag (see $HYPR_DIR/toggles)" >&2
  exit 1
fi

case "${2:-toggle}" in
on) state=on ;;
off) state=off ;;
toggle) [[ -f $flag_file ]] && state=off || state=on ;;
*)
  echo "Usage: toggle-flag.sh <flag> [on|off|toggle]" >&2
  exit 1
  ;;
esac

if [[ $state == "on" ]]; then
  mkdir -p "$STATE_DIR/toggles"
  cp "$source_file" "$flag_file"
else
  rm -f "$flag_file"
fi

hyprctl reload >/dev/null
echo "$state"
