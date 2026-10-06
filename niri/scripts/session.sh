#!/bin/bash

# Log out, restart or shut down from niri after closing every window, so apps like browsers save their session.
# "close" only closes every window and goes to workspace 1 (Ctrl + Shift + Alt + Delete)
# Usage: session.sh close|logout|reboot|shutdown

case "${1:-}" in
close) action="" ;;
logout) action="niri msg action quit --skip-confirmation" ;;
reboot) action="systemctl reboot --no-wall" ;;
shutdown) action="systemctl poweroff --no-wall" ;;
*)
  echo "Usage: session.sh close|logout|reboot|shutdown" >&2
  exit 1
  ;;
esac

# Detached, so it survives the menu that started it being closed
[[ -n $action ]] && nohup bash -c "sleep 2 && $action" >/dev/null 2>&1 &

for id in $(niri msg --json windows | jq -r '.[].id'); do
  niri msg action close-window --id "$id"
done

niri msg action focus-workspace 1
