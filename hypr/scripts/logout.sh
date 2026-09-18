#!/bin/bash

# Log out after closing all windows, so apps like browsers save their session

source "$(dirname "$(readlink -f "$0")")/common.sh"

# Detached, so it survives the terminal or menu that started it being closed
nohup bash -c 'sleep 2 && if uwsm check is-active >/dev/null 2>&1; then uwsm stop; else hyprctl dispatch "hl.dsp.exit()"; fi' >/dev/null 2>&1 &

"$SCRIPTS_DIR/window-close-all.sh"
sleep 1
