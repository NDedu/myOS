#!/bin/bash

# Print the working directory of the shell in the focused terminal window, or $HOME
# (niri version of ~/.config/hypr/scripts/terminal-cwd.sh)

terminal_pid=$(niri msg --json focused-window 2>/dev/null | jq -r '.pid // empty')
cwd=""

if [[ -n $terminal_pid ]]; then
  shell_pid=$(pgrep -P "$terminal_pid" | tail -n1)

  if [[ -n $shell_pid ]]; then
    cwd=$(readlink -f "/proc/$shell_pid/cwd" 2>/dev/null)
    shell=$(readlink -f "/proc/$shell_pid/exe" 2>/dev/null)
    grep -Fqsx "$shell" /etc/shells || cwd=""
  fi
fi

if [[ -d $cwd ]]; then
  echo "$cwd"
else
  echo "$HOME"
fi
