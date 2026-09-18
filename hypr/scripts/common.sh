#!/bin/bash

# Shared helpers for the Hyprland scripts. Sourced, not run.

SCRIPTS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
HYPR_DIR="$(dirname "$SCRIPTS_DIR")"
WAYBAR_SCRIPTS="$HOME/.config/waybar/scripts"
STATE_DIR="$HOME/.local/state/hypr"

# Prefix for launching apps: goes through uwsm when the session is managed by it, plain exec otherwise
# (checks the environment/systemd directly: `uwsm check is-active` is Python and adds ~150ms to every script)
if command -v uwsm-app >/dev/null && { [[ -n ${UWSM_FINALIZE_VARNAMES:-} ]] || systemctl --user is-active --quiet 'wayland-wm@*.service'; }; then
  APP=(uwsm-app --)
else
  APP=()
fi

# Run a Hyprland dispatcher written in Lua config syntax, e.g. hypr_dispatch 'hl.dsp.focus({ workspace = "1" })'
hypr_dispatch() {
  hyprctl dispatch "$1" >/dev/null
}

focused_monitor() {
  hyprctl monitors -j | jq -r '.[] | select(.focused == true).name'
}

# dmenu-style picker: options on stdin, selection on stdout (fuzzel, via the bar's launcher script)
pick() {
  "$WAYBAR_SCRIPTS/launcher.sh" --dmenu "$1"
}

