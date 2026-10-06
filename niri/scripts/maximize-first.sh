#!/bin/bash

# A window opening on an empty workspace takes the full width, as if Super + Alt + F (maximize-column) was pressed,
# like a lone window in Hyprland. Super + Alt + F gives it the normal width back. Started by ../config.kdl,
# follows niri's event stream for as long as the session runs.

declare -A known

tiled_windows_on() {
  niri msg --json windows | jq --argjson ws "$1" '[.[] | select(.workspace_id == $ws and (.is_floating | not))] | length'
}

# One line per event: "all <ids...>", "open <id> <workspace> <floating> <app id>" or "closed <id>"
niri msg --json event-stream | jq --unbuffered -r '
  if .WindowsChanged then "all " + ([.WindowsChanged.windows[].id | tostring] | join(" "))
  elif .WindowOpenedOrChanged then .WindowOpenedOrChanged.window | "open \(.id) \(.workspace_id) \(.is_floating) \(.app_id)"
  elif .WindowClosed then "closed \(.WindowClosed.id)"
  else empty end' | while read -r kind id rest; do
  case $kind in
  all)
    known=()
    for window in $id $rest; do
      known[$window]=1
    done
    ;;
  closed)
    unset "known[$id]"
    ;;
  open)
    # Title changes and moves arrive as "open" too; only a new window counts
    [[ -n ${known[$id]:-} ]] && continue
    known[$id]=1

    read -r workspace floating app_id <<<"$rest"
    [[ $floating == false && $workspace != null && $app_id != org.niri.screensaver ]] || continue
    (($(tiled_windows_on "$workspace") == 1)) || continue

    # maximize-column acts on the focused column, so wait for the new window to get the focus
    for _ in {1..20}; do
      if [[ $(niri msg --json focused-window | jq -r '.id // empty') == "$id" ]]; then
        niri msg action maximize-column
        break
      fi
      sleep 0.05
    done
    ;;
  esac
done
