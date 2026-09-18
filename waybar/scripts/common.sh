#!/bin/bash

# Shared helpers for the Waybar scripts. Sourced, not run.

SCRIPTS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
WAYBAR_DIR="$(dirname "$SCRIPTS_DIR")"

# Prefix for launching apps: goes through uwsm when the session is managed by it, plain exec otherwise
# (checks the environment/systemd directly: `uwsm check is-active` is Python and adds ~150ms to every script)
if command -v uwsm-app >/dev/null && { [[ -n ${UWSM_FINALIZE_VARNAMES:-} ]] || systemctl --user is-active --quiet 'wayland-wm@*.service'; }; then
  APP=(uwsm-app --)
else
  APP=()
fi
