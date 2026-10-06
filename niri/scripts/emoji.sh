#!/bin/bash

# Emoji picker in fuzzel (names from the unicode-emoji package): the pick is typed into the focused window
# with wtype and left on the clipboard (niri version of ~/.config/hypr/scripts/emoji.sh, which pastes through Hyprland)

EMOJI_DATA=/usr/share/unicode/emoji/emoji-test.txt

if [[ ! -f $EMOJI_DATA ]]; then
  notify-send -u low "Emoji picker unavailable" "Install unicode-emoji"
  exit 1
fi

# "1F600 ; fully-qualified # 😀 E1.0 grinning face" -> "😀  grinning face"
selection=$(awk -F'# ' '/; fully-qualified/ {
    split($2, parts, " ")
    name = $2
    sub(/^[^ ]+ E[0-9.]+ /, "", name)
    print parts[1] "  " name
  }' "$EMOJI_DATA" | fuzzel --dmenu --width 50 --prompt "Emoji  ") || exit 0

[[ -n $selection ]] || exit 0
emoji=${selection%%  *}

printf '%s' "$emoji" | wl-copy

# Let keyboard focus return to the window after the picker closes
sleep 0.1
wtype -- "$emoji"
