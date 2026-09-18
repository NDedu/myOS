#!/bin/bash

# Start the terminal screensaver on every monitor (started by hypridle, or "Screensaver" in the system menu)

source "$(dirname "$(readlink -f "$0")")/common.sh"

pgrep -f '[o]rg.hypr.screensaver' >/dev/null && exit 0

focused=$(focused_monitor)

hypr_exec() {
  local command
  printf -v command '%q ' "$@"
  hypr_dispatch "hl.dsp.exec_cmd([[$command]])"
}

# Listen to Hyprland events before spawning, so a fast terminal can't open before we're listening
exec {events}< <(socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock")

# New windows open on the focused monitor, so wait for each one before moving on
wait_for_screensaver_window() {
  local line deadline=$((SECONDS + 5))
  while ((SECONDS < deadline)) && IFS= read -r -t $((deadline - SECONDS)) -u "$events" line; do
    [[ $line == openwindow\>\>*,org.hypr.screensaver,* ]] && return 0
  done
}

for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
  hypr_dispatch "hl.dsp.focus({ monitor = \"$monitor\" })"
  hypr_exec ghostty --class=org.hypr.screensaver --config-file="$HOME/.config/ghostty/screensaver" --font-size=18 -e "$SCRIPTS_DIR/screensaver.sh"
  wait_for_screensaver_window
done

hypr_dispatch "hl.dsp.focus({ monitor = \"$focused\" })"
