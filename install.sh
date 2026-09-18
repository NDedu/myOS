#!/bin/bash

# Install the myOS desktop (Hyprland, Waybar and the rest of these configs) on a fresh Arch system.
# Usage: ./install.sh              copy configs into place (existing ones are backed up)
#        ./install.sh --packages   install packages.txt with pacman first
# Prefer doing it by hand? See install.txt.

set -e

src="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
stamp=$(date +%s)
config="${XDG_CONFIG_HOME:-$HOME/.config}"

step() {
  echo -e "\n\033[1m==> $*\033[0m"
}

# Move an existing file/dir out of the way, then copy ours in
install_path() {
  local from="$src/$1" to="$2"

  if [[ -e $to || -L $to ]]; then
    mv "$to" "$to.bak.$stamp"
    echo "  backed up $to -> $to.bak.$stamp"
  fi

  mkdir -p "$(dirname "$to")"
  cp -r "$from" "$to"
  echo "  $1 -> $to"
}

package_list() {
  grep -v -e '^#' -e '^\s*$' "$src/$1"
}

# Escape a value for the right-hand side of a sed s|...|...| replacement
sed_escape() {
  printf '%s' "$1" | sed 's/[&|\\]/\\&/g'
}

# Arguments ---------------------------------------------------------------------

install_packages=false
case "${1:-}" in
"") ;;
--packages) install_packages=true ;;
*)
  echo "Unknown option: $1" >&2
  echo "Usage: ./install.sh [--packages]   (install.txt has the steps by hand)" >&2
  exit 1
  ;;
esac

# Identity ---------------------------------------------------------------------

# Neither git/config nor XCompose carries a name or email, so they stay out of the repo.
# Asked once here, then written into both. GIT_NAME/GIT_EMAIL skip the questions.
identity_name="${GIT_NAME:-$(git config --global user.name 2>/dev/null || true)}"
identity_email="${GIT_EMAIL:-$(git config --global user.email 2>/dev/null || true)}"

if [[ -t 0 ]]; then
  step "Identity (git commits, and the compose shortcuts for name and email)"
  read -rp "  Name${identity_name:+ [$identity_name]}: " reply || true
  [[ -n $reply ]] && identity_name=$reply
  read -rp "  Email${identity_email:+ [$identity_email]}: " reply || true
  [[ -n $reply ]] && identity_email=$reply
  echo "  Empty leaves them unset: git asks at the first commit."
fi

# Packages -------------------------------------------------------------------

if [[ $install_packages == true ]]; then
  step "Installing packages (pacman)"
  package_list packages.txt | sudo pacman -S --needed -
fi

# Configs ----------------------------------------------------------------------

step "Hyprland (config, hypridle, hyprlock, hyprsunset, scripts, wallpaper)"
install_path hypr "$config/hypr"
chmod +x "$config/hypr/scripts/"*.sh

step "Waybar"
INSTALL_STAMP="$stamp" bash "$src/waybar/install.sh"

step "Notifications, OSD, launcher"
install_path mako "$config/mako"
install_path swayosd "$config/swayosd"
install_path fuzzel "$config/fuzzel"

step "Terminal (ghostty, bash, prompt, tmux, btop, git, lazygit, nvim)"
install_path ghostty "$config/ghostty"
install_path starship.toml "$config/starship.toml"
install_path tmux "$config/tmux"
install_path btop "$config/btop"
install_path fontconfig "$config/fontconfig"
install_path bash/bashrc "$HOME/.bashrc"
for file in envs shell aliases functions init inputrc; do
  install_path "bash/$file" "$config/bash/$file"
done
install_path XCompose "$HOME/.XCompose"

# The two shortcuts under "# Identification": Right Alt + space + n types the name, + e the email
if [[ -n $identity_name$identity_email ]]; then
  [[ -n $identity_name ]] && sed -i "s|^\(<Multi_key> <space> <n> : \).*|\1\"$(sed_escape "$identity_name")\"|" "$HOME/.XCompose"
  [[ -n $identity_email ]] && sed -i "s|^\(<Multi_key> <space> <e> : \).*|\1\"$(sed_escape "$identity_email")\"|" "$HOME/.XCompose"
  echo "  identity -> $HOME/.XCompose (Right Alt + space + n / e)"
fi
install_path git "$config/git"

if command -v git >/dev/null && [[ -n $identity_name$identity_email ]]; then
  [[ -n $identity_name ]] && git config --file "$config/git/config" user.name "$identity_name"
  [[ -n $identity_email ]] && git config --file "$config/git/config" user.email "$identity_email"
  echo "  identity -> $config/git/config"
fi
install_path lazygit "$config/lazygit"
install_path nvim "$config/nvim"
install_path imv "$config/imv"
install_path yazi "$config/yazi"
install_path zed "$config/zed"

install_path uwsm "$config/uwsm"

step "File managers (yazi is the default, Nautilus and Dolphin kept) and default apps"
install_path mimeapps.list "$config/mimeapps.list"

# Folders open yazi in ghostty. The package's own yazi.desktop is Terminal=true, which needs a terminal
# nothing outside GNOME/KDE can find, so this entry (same name, so it wins) runs ghostty itself.
install_path applications/yazi.desktop "$HOME/.local/share/applications/yazi.desktop"
command -v update-desktop-database >/dev/null && update-desktop-database "$HOME/.local/share/applications" 2>/dev/null

# Nautilus sidebar bookmarks
mkdir -p "$config/gtk-3.0"
[[ -f $config/gtk-3.0/bookmarks ]] && mv "$config/gtk-3.0/bookmarks" "$config/gtk-3.0/bookmarks.bak.$stamp"
sed "s|\$HOME|$HOME|g" "$src/nautilus/bookmarks" >"$config/gtk-3.0/bookmarks"
echo "  nautilus/bookmarks -> $config/gtk-3.0/bookmarks"

# Nautilus and file dialog preferences (show hidden files, folders not sorted first)
if command -v dconf >/dev/null; then
  dconf load / <"$src/nautilus/settings.dconf"
  echo "  nautilus/settings.dconf -> dconf"
fi

install_path dolphin/dolphinrc "$config/dolphinrc"
install_path dolphin/kiorc "$config/kiorc"
install_path dolphin/kdeglobals "$config/kdeglobals"

# Dark GTK theme and icons for Nautilus and other GTK apps. Qt apps like Dolphin follow these through QT_QPA_PLATFORMTHEME=gtk3.
if command -v gsettings >/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
  echo "  GTK: Adwaita-dark, prefer-dark, Papirus-Dark icons"
fi

# Dolphin's "Open With" list is empty outside Plasma without an applications menu
if command -v kbuildsycoca6 >/dev/null && [[ -f /etc/xdg/menus/arch-applications.menu ]]; then
  XDG_MENU_PREFIX=arch- kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
  echo "  Rebuilt KDE service cache for Open With"
fi

mkdir -p "$HOME/Pictures" "$HOME/Videos"

step "gnome-keyring (passwords for browsers and apps)"
# Chromium-based browsers don't detect a keyring outside GNOME/KDE, so tell them to use it
install_path browser/chromium-flags.conf "$config/chromium-flags.conf"
install_path browser/brave-flags.conf "$config/brave-flags.conf"

if systemctl --user enable gnome-keyring-daemon.socket >/dev/null 2>&1; then
  echo "  Enabled gnome-keyring-daemon.socket"
fi

# Services -----------------------------------------------------------------------

has_battery() {
  ls /sys/class/power_supply/BAT* >/dev/null 2>&1
}

step "Power"
if has_battery; then
  mkdir -p "$config/systemd/user"
  cp "$src"/systemd/user/battery-monitor.* "$config/systemd/user/"
  systemctl --user daemon-reload
  systemctl --user enable --now battery-monitor.timer >/dev/null 2>&1 && echo "  Enabled low battery notifications"
else
  echo "  No battery: skipping the low battery warning"
fi

# Missing packages ---------------------------------------------------------------

step "Checking packages"
missing=()
for package in $(package_list packages.txt); do
  pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
done

if ((${#missing[@]})); then
  echo "  Not installed yet: ${missing[*]}"
  echo "  Install them with: sudo pacman -S --needed ${missing[*]}"
else
  echo "  All packages installed"
fi

cat <<EOF

Done. Log in to Hyprland through uwsm (pick "Hyprland (uwsm-managed)" in the display manager,
or run: uwsm start hyprland.desktop). Press SUPER + K to see every keybinding.

Optional extras (passwordless keyring, power key menu) are in install.txt.
EOF
