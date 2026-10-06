#!/bin/bash

# Universal copy, paste and cut (Super + C / V / X), as in Hyprland: Ctrl + C / V / X in apps, Ctrl + Insert and
# Shift + Insert in terminals, where Ctrl + C would stop the running program. The keys are sent with wtype
# (niri version of hypr/modules/bindings/clipboard.lua)
# Usage: universal-clipboard.sh copy|paste|cut

app_id=$(niri msg --json focused-window 2>/dev/null | jq -r '.app_id // empty')

# The same terminals as the "terminal" tag in hypr/modules/windows.lua, plus this setup's screensaver
terminal=false
if [[ $app_id =~ ^(Alacritty|kitty|com\.mitchellh\.ghostty|foot|org\.codeberg\.dnkl\.foot|org\.wezfurlong\.wezterm|org\.hypr\..*|org\.waybar\..*|org\.niri\..*)$ ]]; then
  terminal=true
fi

case "${1:-}" in
copy)
  if [[ $terminal == true ]]; then
    wtype -M ctrl -k Insert -m ctrl
  else
    wtype -M ctrl -k c -m ctrl
  fi
  ;;
paste)
  if [[ $terminal == true ]]; then
    wtype -M shift -k Insert -m shift
  else
    wtype -M ctrl -k v -m ctrl
  fi
  ;;
cut)
  wtype -M ctrl -k x -m ctrl
  ;;
*)
  echo "Usage: universal-clipboard.sh copy|paste|cut" >&2
  exit 1
  ;;
esac
