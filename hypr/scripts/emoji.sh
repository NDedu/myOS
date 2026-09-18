#!/bin/bash

# Emoji picker in fuzzel (names from the unicode-emoji package); the pick is pasted into the focused window

source "$(dirname "$(readlink -f "$0")")/common.sh"

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

[[ -n $selection ]] && printf '%s' "${selection%%  *}" | "$SCRIPTS_DIR/paste.sh"
