#!/bin/bash

# Open ghostty in the active terminal's directory, optionally running a command
# Usage: launch-terminal.sh [-e command args...]

source "$(dirname "$(readlink -f "$0")")/common.sh"

exec setsid "${APP[@]}" ghostty --working-directory="$("$SCRIPTS_DIR/terminal-cwd.sh")" "$@"
