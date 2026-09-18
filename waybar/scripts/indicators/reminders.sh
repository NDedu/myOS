#!/bin/bash

# Reminder indicator: bright with the list in the tooltip while reminders are pending, dimmed otherwise.
# Left click shows the reminders (or sets one when there are none), right click sets a new one.

reminder="$HOME/.config/hypr/scripts/reminder.sh"

if [[ ${1:-} == "--click" ]]; then
  if "$reminder" show --json | grep -q '"class":"active"'; then
    exec "$reminder" show
  else
    exec "$reminder" set
  fi
fi

if [[ -x $reminder ]]; then
  exec "$reminder" show --json
else
  echo '{"text": ""}'
fi
