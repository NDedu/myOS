#!/bin/bash

# Focus a window whose app id or title matches a pattern, or run the command
# (niri version of ~/.config/hypr/scripts/launch-or-focus.sh)
# Usage: launch-or-focus.sh <pattern> <command> [args...]

if (($# < 2)); then
  echo "Usage: launch-or-focus.sh <pattern> <command> [args...]" >&2
  exit 1
fi

pattern=$1
shift

id=$(niri msg --json windows | jq -r --arg p "$pattern" '
  first(.[] | select(((.app_id // "") | test($p; "i")) or ((.title // "") | test($p; "i"))) | .id) // empty')

if [[ -n $id ]]; then
  niri msg action focus-window --id "$id"
else
  exec setsid "$@"
fi
