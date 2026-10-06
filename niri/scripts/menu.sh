#!/bin/bash

# The menus in niri (the bar's logo, Super + Space): the Hyprland menu (~/.config/hypr/scripts/menu.sh) without
# what needs Hyprland (workspace layout, touchpad, webcam), with niri's own screenshot tool, keybinding list and
# logout, swaylock and swayidle for locking and idle, and wlsunset for the night light
# Usage: menu.sh [system|capture|reminder|screenrecord|toggle]

SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
HYPR_SCRIPTS="$HOME/.config/hypr/scripts"
WAYBAR_SCRIPTS="$HOME/.config/waybar/scripts"

# Shared with the Hyprland menu, so "Suspend in System Menu" is one setting for both
FLAGS_DIR="$HOME/.local/state/hypr/flags"

# Set when opened straight into a submenu, so "back" closes instead of showing the main menu
BACK_TO_EXIT=false

back_to() {
  if [[ $BACK_TO_EXIT == "true" ]]; then
    exit 0
  fi
  "${1:-show_main_menu}"
}

menu() {
  echo -e "$2" | "$WAYBAR_SCRIPTS/launcher.sh" --dmenu "$1"
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
  *Lock*) swaylock ;;
  *Wallpaper*) "$HYPR_SCRIPTS/wallpaper-reload.sh" ;;
  *Suspend*) systemctl suspend ;;
  *Hibernate*) systemctl hibernate ;;
  *Logout*) "$SCRIPTS_DIR/session.sh" logout ;;
  *Restart*) "$SCRIPTS_DIR/session.sh" reboot ;;
  *Shutdown*) "$SCRIPTS_DIR/session.sh" shutdown ;;
  *) back_to ;;
  esac
}

# Screenshot is niri's own tool (also on PRINT). Text, QR and color use the Hyprland setup's scripts,
# which don't depend on Hyprland
show_capture_menu() {
  case $(menu "Capture" "󰄀    Screenshot\n󰻂    Screenrecord\n󰴑    Text Extraction\n󰐲    QR Code\n󰈊    Color") in
  *Screenshot*) niri msg action screenshot ;;
  *Screenrecord*) show_screenrecord_menu ;;
  *Text*) "$HYPR_SCRIPTS/ocr.sh" ;;
  *QR*) "$HYPR_SCRIPTS/qr.sh" ;;
  *Color*) pkill hyprpicker || hyprpicker -a ;;
  *) back_to ;;
  esac
}

show_reminder_menu() {
  case $(menu "Reminder" "󰀠    Set one\n󰉹    Show all\n󰆴    Clear all") in
  *Set*) "$HYPR_SCRIPTS/reminder.sh" set ;;
  *Show*) "$HYPR_SCRIPTS/reminder.sh" show ;;
  *Clear*) "$HYPR_SCRIPTS/reminder.sh" clear ;;
  *) back_to ;;
  esac
}

# The Hyprland picker needs hyprctl, so recording goes through the screen sharing portal instead:
# it asks which screen or window to record. Clicking the bar's recording icon stops it, as in Hyprland
show_screenrecord_menu() {
  local record="$WAYBAR_SCRIPTS/screenrecording.sh"

  # A running recording is stopped instead
  if pgrep -f "^gpu-screen-recorder" >/dev/null; then
    exec "$record" --stop-recording
  fi

  export SCREENRECORD_USE_PORTAL=true

  case $(menu "Screenrecord" "󰝟    With no audio\n󰕾    With desktop audio\n󰍬    With desktop + microphone audio") in
  *"With no audio") "$record" ;;
  *"With desktop audio") "$record" --with-desktop-audio ;;
  *"With desktop + microphone audio") "$record" --with-desktop-audio --with-microphone-audio ;;
  *) back_to show_capture_menu ;;
  esac
}

show_toggle_menu() {
  case $(menu "Toggle" "󰂛    Do Not Disturb\n󰅶    Idle Lock\n󰔎    Nightlight\n󰖧    Top Bar\n󰒲    Suspend in System Menu") in
  *Disturb*) "$WAYBAR_SCRIPTS/toggle-notification-silencing.sh" ;;
  *Idle*) "$SCRIPTS_DIR/idle.sh" ;;
  *Nightlight*) "$SCRIPTS_DIR/nightlight.sh" ;;
  *Bar*) "$SCRIPTS_DIR/waybar.sh" toggle ;;
  *Suspend*) toggle_flag suspend-off "󰒲    Suspend removed from system menu" "󰒲    Suspend available in system menu" ;;
  *) back_to ;;
  esac
}

# Opening the menu again closes it
pkill -x fuzzel && exit 0

case "${1:-}" in
"") show_main_menu ;;
system | capture | reminder | screenrecord | toggle)
  BACK_TO_EXIT=true
  "show_${1}_menu"
  ;;
*)
  echo "Usage: menu.sh [system|capture|reminder|screenrecord|toggle]" >&2
  exit 1
  ;;
esac
