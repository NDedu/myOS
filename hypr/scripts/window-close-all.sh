#!/bin/bash

# Close all open windows and go to workspace 1

source "$(dirname "$(readlink -f "$0")")/common.sh"

hyprctl clients -j | jq -r '.[].address' | while read -r address; do
  hypr_dispatch "hl.dsp.window.close({ window = \"address:$address\" })"
done

hypr_dispatch 'hl.dsp.focus({ workspace = "1" })'
