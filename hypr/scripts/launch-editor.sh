#!/bin/bash

# Open $EDITOR: terminal editors in a new terminal, GUI editors directly
# Usage: launch-editor.sh [path...]

source "$(dirname "$(readlink -f "$0")")/common.sh"

editor=${EDITOR:-nvim}
command -v "${editor%% *}" >/dev/null || editor=nvim

case "$(basename "${editor%% *}")" in
nvim | vim | nano | micro | hx | helix)
  exec setsid "${APP[@]}" ghostty -e $editor "$@"
  ;;
*)
  exec setsid "${APP[@]}" $editor "$@"
  ;;
esac
