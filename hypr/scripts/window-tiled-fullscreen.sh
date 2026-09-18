#!/bin/bash

# Toggle "tiled fullscreen": the app thinks it is fullscreen but keeps its tile

source "$(dirname "$(readlink -f "$0")")/common.sh"

if [[ $(hyprctl activewindow -j | jq -r '.fullscreenClient // 0') == "2" ]]; then
  hypr_dispatch 'hl.dsp.window.fullscreen_state({ internal = 0, client = 0 })'
else
  hypr_dispatch 'hl.dsp.window.fullscreen_state({ internal = 0, client = 2 })'
fi
