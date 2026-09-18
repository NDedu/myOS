#!/bin/bash

# Copy stdin to the clipboard and paste it into the focused window (used by emoji.sh)

source "$(dirname "$(readlink -f "$0")")/common.sh"

wl-copy

# Let keyboard focus return to the window after the picker closes
sleep 0.1

# Shift+Insert pastes in terminals and regular apps alike
hypr_dispatch 'hl.dsp.send_key_state({ mods = "SHIFT", key = "Insert", state = "down" })'
sleep 0.05
hypr_dispatch 'hl.dsp.send_key_state({ mods = "SHIFT", key = "Insert", state = "up" })'
