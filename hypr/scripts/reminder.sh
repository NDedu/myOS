#!/bin/bash

# Desktop notification reminders (systemd user timers)
# Usage: reminder.sh set                 ask for minutes and a message (fuzzel)
#        reminder.sh <minutes> [message]
#        reminder.sh show [--json]       list upcoming reminders (--json is for the bar icon)
#        reminder.sh clear

set -euo pipefail

source "$(dirname "$(readlink -f "$0")")/common.sh"

MESSAGES_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-reminders"

usage() {
  cat <<'EOF'
Desktop notification reminders (systemd user timers)
Usage: reminder.sh set                 ask for minutes and a message (fuzzel)
       reminder.sh <minutes> [message]
       reminder.sh show [--json]       list upcoming reminders (--json is for the bar icon)
       reminder.sh clear
EOF
}

refresh_bar() {
  pkill -RTMIN+11 waybar 2>/dev/null || true
}

format_remaining() {
  local minutes=$(($1 / 60)) remainder=$(($1 % 60))

  if ((minutes > 0 && remainder > 0)); then
    echo "${minutes}m ${remainder}s"
  elif ((minutes > 0)); then
    echo "${minutes}m"
  else
    echo "${remainder}s"
  fi
}

# One line per pending reminder: <unit> <tab> <epoch seconds when it fires>
pending_reminders() {
  local now unit next
  now=$(date +%s)

  systemctl --user list-timers --all --output=json "hypr-reminder-*.timer" 2>/dev/null |
    jq -r '.[] | [.unit, .next] | @tsv' |
    while IFS=$'\t' read -r unit next; do
      [[ -z $unit || -z $next || $next == "null" ]] && continue
      next=$((next / 1000000))
      ((next > now)) && printf '%s\t%s\n' "${unit%.timer}" "$next"
    done
}

# "Check the oven" or "10-min reminder"
reminder_label() {
  local unit=$1 minutes

  if [[ -f $MESSAGES_DIR/$unit.message ]]; then
    cat "$MESSAGES_DIR/$unit.message"
  else
    minutes=${unit#hypr-reminder-}
    echo "${minutes%%m-*}-min reminder"
  fi
}

show() {
  local unit next now body=""
  now=$(date +%s)

  while IFS=$'\t' read -r unit next; do
    body+="$(reminder_label "$unit") in $(format_remaining $((next - now))) ($(date -d "@$next" +%-H:%M))"$'\n'
  done < <(pending_reminders)

  body=${body%$'\n'}
  notify-send -u low "󰢌    Upcoming reminders" "${body:-No reminders set}"
}

# For the bar icon: bright with a list in the tooltip while reminders are pending, dimmed otherwise
show_json() {
  local unit next count=0 tooltip=""

  while IFS=$'\t' read -r unit next; do
    count=$((count + 1))
    tooltip+="$(reminder_label "$unit") at $(date -d "@$next" +%-H:%M)"$'\n'
  done < <(pending_reminders)

  if ((count > 0)); then
    jq -cn --arg tooltip "${tooltip%$'\n'}" '{text: "󰢌", tooltip: ($tooltip | @html), class: "active"}'
  else
    jq -cn '{text: "󰢌", tooltip: "Set Reminder", class: "inactive"}'
  fi
}

clear_all() {
  local units
  # Same source as pending_reminders, but every timer, including one about to fire
  units=$(systemctl --user list-timers --all --output=json "hypr-reminder-*.timer" 2>/dev/null |
    jq -r '.[].unit | select(. != null)' || true)

  if [[ -n $units ]]; then
    xargs -r systemctl --user stop <<<"$units" || true
  fi

  rm -f "$MESSAGES_DIR"/hypr-reminder-*.message
  refresh_bar
  notify-send -u low "󰢌    All reminders have been cleared"
}

ask() {
  fuzzel --dmenu --prompt-only "$1  " 2>/dev/null || true
}

# Ask for the minutes (again if it isn't a number), then an optional message
set_interactive() {
  local minutes message

  while true; do
    minutes=$(ask "Remind in minutes")
    [[ -z $minutes ]] && exit 0
    [[ $minutes =~ ^[0-9]+$ ]] && ((minutes > 0)) && break
    notify-send -u low "󰢌    Invalid reminder" "Enter the number of minutes"
  done

  message=$(ask "Reminder message (optional)")
  set_reminder "$minutes" "$message"
}

set_reminder() {
  local minutes=$1 message=${2:-} unit title

  if [[ ! $minutes =~ ^[0-9]+$ ]] || ((minutes == 0)); then
    echo "Usage: reminder.sh <minutes> [message]" >&2
    exit 1
  fi

  unit="hypr-reminder-${minutes}m-$(date +%s%N)"
  mkdir -p "$MESSAGES_DIR"

  if [[ -n $message ]]; then
    printf '%s' "$message" >"$MESSAGES_DIR/$unit.message"
    title="$message in $minutes minutes"
  else
    title="Reminder set for $minutes minutes"
    message="Your $minutes minutes are up"
  fi

  systemd-run --user --quiet --collect --on-active="${minutes}m" --unit="$unit" \
    bash -c 'notify-send -u normal "󰢌    Reminder" "$1"; rm -f "$2"; pkill -RTMIN+11 waybar || true' \
    bash "$message" "$MESSAGES_DIR/$unit.message"

  refresh_bar
  notify-send -u low "󰢌    $title" "You'll be reminded at $(date -d "+$minutes minutes" +%-H:%M)"
}

case "${1:-}" in
set) set_interactive ;;
show | list)
  if [[ ${2:-} == "--json" ]]; then show_json; else show; fi
  ;;
clear) clear_all ;;
"" | -h | --help) usage ;;
*) set_reminder "$1" "${*:2}" ;;
esac
