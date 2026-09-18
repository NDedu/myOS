#!/bin/bash

# The file manager: yazi in a terminal window, or Nautilus with --nautilus.
# Usage: launch-file-manager.sh [--cwd]              yazi (--cwd: in the active terminal's directory)
#        launch-file-manager.sh --nautilus [--cwd]   Nautilus instead
#        launch-file-manager.sh [--nautilus] <dir>   a directory to open

source "$(dirname "$(readlink -f "$0")")/common.sh"

nautilus=false
if [[ ${1:-} == "--nautilus" ]]; then
  nautilus=true
  shift
fi

if [[ ${1:-} == "--cwd" ]]; then
  directory=$("$SCRIPTS_DIR/terminal-cwd.sh")
else
  directory=${1:-$HOME}
fi

if [[ $nautilus == "true" ]]; then
  exec setsid "${APP[@]}" nautilus --new-window "$directory"
fi

# Its own app-id, so window rules can match yazi rather than every ghostty window
exec setsid "${APP[@]}" ghostty --class=org.hypr.yazi -e yazi "$directory"
