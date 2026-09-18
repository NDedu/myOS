#!/bin/bash

# Install this Waybar setup: copies it to ~/.config/waybar (backing up an existing one)
# and lists any packages the bar's features still need.

set -e

src="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
dest="$HOME/.config/waybar"

if [[ $src != "$dest" ]]; then
  if [[ -e $dest ]]; then
    # install.sh passes its own stamp, so one run leaves one timestamp everywhere
    backup="$dest.bak.${INSTALL_STAMP:-$(date +%s)}"
    mv "$dest" "$backup"
    echo "Backed up existing $dest to $backup"
  fi
  mkdir -p "$(dirname "$dest")"
  cp -r "$src" "$dest"
  echo "Copied Waybar config to $dest"
fi

chmod +x "$dest/install.sh" "$dest"/scripts/*.sh "$dest"/scripts/indicators/*.sh

# Dependencies: <package> <what needs it> <commands, any one of which satisfies it>
missing=()
check() {
  local package=$1 purpose=$2
  shift 2
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null && return
  done
  missing+=("$(printf '%-28s %s' "$package" "$purpose")")
}

check waybar "the bar itself" waybar
check jq "weather, window focus" jq
check curl "weather" curl
check libnotify "notifications from clicks" notify-send
check pamixer "right-click mute on volume" pamixer
check ghostty "terminals opened from the bar (or alacritty/kitty/foot)" ghostty xdg-terminal-exec alacritty kitty foot
check gum "timezone picker, 'Done' prompt" gum fzf
check fuzzel "logo launcher, power profile menu (or wofi/rofi)" fuzzel wofi rofi
check btop "cpu click" btop
check calcurse "calendar icon click" calcurse
check networkmanager "network click (nmtui)" nmtui impala
check bluetui "bluetooth click (or blueman)" bluetui blueman-manager
check wiremix "audio click (or pavucontrol)" wiremix pavucontrol
check power-profiles-daemon "battery click" powerprofilesctl
check upower "battery right-click" upower
check pacman-contrib "update icon (checkupdates)" checkupdates
check hypridle "idle lock indicator" hypridle
check mako "notification silencing (or swaync/dunst)" makoctl swaync-client dunstctl
check gpu-screen-recorder "screen recording" gpu-screen-recorder
check slurp "screen recording region picker" slurp
check hyprpicker "screen recording region picker" hyprpicker
check ffmpeg "screen recording post-processing" ffmpeg

if ! fc-list 2>/dev/null | grep -qi "JetBrainsMonoNL Nerd Font"; then
  missing+=("$(printf '%-28s %s' ttf-jetbrains-mono-nerd "bar font and icons")")
fi

if ((${#missing[@]})); then
  echo -e "\nMissing packages (the rest of the bar works without them):"
  printf '  %s\n' "${missing[@]}"
fi

cat <<EOF

Next steps:
  1. Load the Hyprland integration (already done by the myOS hypr config):
       hyprland.lua:  dofile(os.getenv("HOME") .. "/.config/waybar/hyprland.lua")
       hyprland.conf: source = ~/.config/waybar/hyprland.conf
  2. Start or restart the bar:   ~/.config/waybar/scripts/restart-waybar.sh
EOF
