#!/bin/bash

# Menus (system, capture, reminders, screen recording, toggles) in fuzzel
# Usage: menu.sh [system|capture|reminder|screenrecord|toggle|power]

source "$(dirname "$(readlink -f "$0")")/common.sh"

FLAGS_DIR="$STATE_DIR/flags"

# Set when opened straight into a submenu, so "back" closes instead of showing the main menu
BACK_TO_EXIT=false

back_to() {
  if [[ $BACK_TO_EXIT == "true" ]]; then
    exit 0
  fi
  "${1:-show_main_menu}"
}

menu() {
  echo -e "$2" | pick "$1"
}

flag_enabled() {
  [[ -f $FLAGS_DIR/$1 ]]
}

# toggle_flag <name> <message when turned on> <message when turned off>
toggle_flag() {
  mkdir -p "$FLAGS_DIR"
  if flag_enabled "$1"; then
    rm -f "$FLAGS_DIR/$1"
    notify-send -u low "$3"
  else
    touch "$FLAGS_DIR/$1"
    notify-send -u low "$2"
  fi
}

hibernation_available() {
  [[ -f /sys/power/image_size && -r /sys/power/resume && $(</sys/power/resume) != "0:0" ]] || return 1
  local swap_kb
  swap_kb=$(awk '!/Filename|zram/ { sum += $3 } END { print sum + 0 }' /proc/swaps)
  ((swap_kb * 1024 > $(</sys/power/image_size)))
}

show_main_menu() {
  case $(menu "Go" "󰀻    Apps\n󰄀    Capture\n󰢌    Reminder\n󰔡    Toggle\n󰁹    Power Profile\n󰌌    Keybindings\n󰒓    System") in
  *Apps*) "$WAYBAR_SCRIPTS/launcher.sh" ;;
  *Capture*) show_capture_menu ;;
  *Reminder*) show_reminder_menu ;;
  *Toggle*) show_toggle_menu ;;
  *Power*) "$WAYBAR_SCRIPTS/power-profile-menu.sh" ;;
  *Keybindings*) "$SCRIPTS_DIR/keybindings.sh" ;;
  *System*) show_system_menu ;;
  esac
}

show_system_menu() {
  local options="󱄄    Screensaver\n󰌾    Lock\n󰋩    Reload Wallpaper"
  flag_enabled suspend-off || options="$options\n󰒲    Suspend"
  hibernation_available && options="$options\n󰜗    Hibernate"
  options="$options\n󰍃    Logout\n󰜉    Restart\n󰐥    Shutdown"

  case $(menu "System" "$options") in
  *Screensaver*) "$SCRIPTS_DIR/launch-screensaver.sh" ;;
  *Lock*) "$SCRIPTS_DIR/lock.sh" ;;
  *Wallpaper*) "$SCRIPTS_DIR/wallpaper-reload.sh" ;;
  *Suspend*) systemctl suspend ;;
  *Hibernate*) systemctl hibernate ;;
  *Logout*) "$SCRIPTS_DIR/logout.sh" ;;
  *Restart*) "$SCRIPTS_DIR/reboot.sh" ;;
  *Shutdown*) "$SCRIPTS_DIR/shutdown.sh" ;;
  *) back_to ;;
  esac
}

show_capture_menu() {
  case $(menu "Capture" "󰄀    Screenshot\n󰻂    Screenrecord\n󰴑    Text Extraction\n󰐲    QR Code\n󰈊    Color") in
  *Screenshot*) "$SCRIPTS_DIR/screenshot.sh" ;;
  *Screenrecord*) show_screenrecord_menu ;;
  *Text*) "$SCRIPTS_DIR/ocr.sh" ;;
  *QR*) "$SCRIPTS_DIR/qr.sh" ;;
  *Color*) pkill hyprpicker || hyprpicker -a ;;
  *) back_to ;;
  esac
}

show_reminder_menu() {
  case $(menu "Reminder" "󰀠    Set one\n󰉹    Show all\n󰆴    Clear all") in
  *Set*) "$SCRIPTS_DIR/reminder.sh" set ;;
  *Show*) "$SCRIPTS_DIR/reminder.sh" show ;;
  *Clear*) "$SCRIPTS_DIR/reminder.sh" clear ;;
  *) back_to ;;
  esac
}

webcam_devices() {
  v4l2-ctl --list-devices 2>/dev/null | while IFS= read -r line; do
    if [[ $line != $'\t'* && -n $line ]]; then
      IFS= read -r device || break
      device=$(tr -d '\t' <<<"$device")
      [[ -n $device ]] && echo "$device  $line"
    fi
  done
}

show_screenrecord_menu() {
  local record="$WAYBAR_SCRIPTS/screenrecording.sh"

  # A running recording is stopped instead
  if pgrep -f "^gpu-screen-recorder" >/dev/null; then
    exec "$record" --stop-recording
  fi

  case $(menu "Screenrecord" "󰝟    With no audio\n󰕾    With desktop audio\n󰍬    With desktop + microphone audio\n󰖠    With desktop + microphone audio + webcam") in
  *"With no audio") "$record" ;;
  *"With desktop audio") "$record" --with-desktop-audio ;;
  *"With desktop + microphone audio") "$record" --with-desktop-audio --with-microphone-audio ;;
  *"webcam")
    local devices device
    devices=$(webcam_devices)
    if [[ -z $devices ]]; then
      notify-send -u critical "No webcam devices found"
      return 1
    elif (($(wc -l <<<"$devices") == 1)); then
      device=$(awk '{ print $1 }' <<<"$devices")
    else
      device=$(menu "Select Webcam" "$devices" | awk '{ print $1 }')
    fi
    [[ -n $device ]] && "$record" --with-desktop-audio --with-microphone-audio --with-webcam --webcam-device="$device"
    ;;
  *) back_to show_capture_menu ;;
  esac
}

show_toggle_menu() {
  # Window gaps and the single-window aspect ratio are on SUPER + SHIFT/CTRL + BACKSPACE,
  # the laptop display and mirroring on SUPER + CTRL + (ALT +) DELETE.
  local options="󰂛    Do Not Disturb\n󰅶    Idle Lock\n󰔎    Nightlight\n󰖧    Top Bar\n󱂬    Workspace Layout (tiling or scrolling)\n󰒲    Suspend in System Menu"
  hyprctl devices -j | jq -e '.mice[] | select(.name | test("touchpad|trackpad"; "i"))' >/dev/null && options="$options\n󰍽    Touchpad"

  case $(menu "Toggle" "$options") in
  *Disturb*) "$WAYBAR_SCRIPTS/toggle-notification-silencing.sh" ;;
  *Idle*) "$WAYBAR_SCRIPTS/toggle-idle.sh" ;;
  *Nightlight*) "$SCRIPTS_DIR/toggle-nightlight.sh" ;;
  *Bar*) "$WAYBAR_SCRIPTS/toggle-waybar.sh" ;;
  *Layout*) "$SCRIPTS_DIR/workspace-layout-toggle.sh" ;;
  *Suspend*) toggle_flag suspend-off "󰒲    Suspend removed from system menu" "󰒲    Suspend available in system menu" ;;
  *Touchpad*) "$SCRIPTS_DIR/toggle-touchpad.sh" ;;
  *) back_to ;;
  esac
}

# Pressing the menu key again closes an open menu
pkill -x fuzzel && exit 0

case "${1:-}" in
"") show_main_menu ;;
system)
  BACK_TO_EXIT=true
  show_system_menu
  ;;
capture)
  BACK_TO_EXIT=true
  show_capture_menu
  ;;
reminder)
  BACK_TO_EXIT=true
  show_reminder_menu
  ;;
screenrecord)
  BACK_TO_EXIT=true
  show_screenrecord_menu
  ;;
toggle)
  BACK_TO_EXIT=true
  show_toggle_menu
  ;;
power) "$WAYBAR_SCRIPTS/power-profile-menu.sh" ;;
*)
  echo "Usage: menu.sh [system|capture|reminder|screenrecord|toggle|power]" >&2
  exit 1
  ;;
esac
