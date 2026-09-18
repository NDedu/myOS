#!/bin/bash

# Focus a window whose class or title matches a pattern, or run the launch command
# Usage: launch-or-focus.sh <window-pattern> [launch-command]

source "$(dirname "$(readlink -f "$0")")/common.sh"

if (($# == 0)); then
  echo "Usage: launch-or-focus.sh <window-pattern> [launch-command]"
  exit 1
fi

pattern="$1"
command="${2:-"${APP[*]} $pattern"}"
address=$(hyprctl clients -j | jq -r --arg p "$pattern" '.[] | select((.class | test("\\b" + $p + "\\b"; "i")) or (.title | test("\\b" + $p + "\\b"; "i"))) | .address' | head -n1)

if [[ -n $address ]]; then
  hypr_dispatch "hl.dsp.focus({ window = \"address:$address\" })"
else
  eval exec setsid $command
fi
