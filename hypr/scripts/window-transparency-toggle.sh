#!/bin/bash

# Toggle transparency for the focused window

source "$(dirname "$(readlink -f "$0")")/common.sh"

address=$(hyprctl activewindow -j | jq -r '.address')
hypr_dispatch "hl.dsp.window.set_prop({ window = \"address:$address\", prop = \"opaque\", value = \"toggle\" })"
