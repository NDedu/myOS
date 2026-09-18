#!/bin/bash

# Toggle the current workspace between the dwindle and scrolling layouts (remembered across reloads)

source "$(dirname "$(readlink -f "$0")")/common.sh"

workspace=$(hyprctl activeworkspace -j | jq -r '.id')
[[ $workspace =~ ^-?[0-9]+$ ]] || exit 1

case "$(hyprctl activeworkspace -j | jq -r '.tiledLayout')" in
dwindle) layout=scrolling ;;
*) layout=dwindle ;;
esac

rule="hl.workspace_rule({ workspace = \"$workspace\", layout = \"$layout\" })"

mkdir -p "$STATE_DIR/workspace-layouts"
echo "$rule" >"$STATE_DIR/workspace-layouts/$workspace.lua"

hyprctl eval "$rule" >/dev/null
notify-send -u low "󱂬    Workspace layout set to $layout"
