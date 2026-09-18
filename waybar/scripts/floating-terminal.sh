#!/bin/bash

# Run a command in a floating terminal: shows the logo first and waits for a key press when done
# Usage: floating-terminal.sh <command>

source "$(dirname "$(readlink -f "$0")")/common.sh"

if [[ $1 == "--inside" ]]; then
  shift
  clear

  if [[ -f $WAYBAR_DIR/logo.txt ]]; then
    echo -e "\033[32m"
    cat "$WAYBAR_DIR/logo.txt"
    echo -e "\033[0m"
    echo
  fi

  bash -c "$*"

  if (($? != 130)); then
    echo
    if command -v gum >/dev/null; then
      gum spin --spinner "globe" --title "Done! Press any key to close..." -- bash -c 'read -n 1 -s'
    else
      read -n 1 -s -r -p "Done! Press any key to close..."
    fi
  fi
  exit
fi

# --wait so callers can act once the terminal closes (ex: refresh Waybar after an update)
exec setsid --wait "${APP[@]}" "$SCRIPTS_DIR/terminal.sh" org.waybar.terminal "$SCRIPTS_DIR/floating-terminal.sh" --inside "$@"
