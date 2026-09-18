#!/bin/bash

# Screensaver: ../screensaver.txt centered on a black screen in the solitude colors, static,
# until a key is pressed or the window loses focus. Pure bash, no packages needed.
# Runs inside the terminal opened by launch-screensaver.sh.

source "$(dirname "$(readlink -f "$0")")/common.sh"

export LC_ALL=${LC_ALL:-C.UTF-8} # count block characters as one character each

text="$HYPR_DIR/screensaver.txt"

screensaver_in_focus() {
  hyprctl activewindow -j | jq -e '.class == "org.hypr.screensaver"' >/dev/null 2>&1
}

exit_screensaver() {
  printf '\033[?25h'
  hyprctl eval 'hl.config({ cursor = { invisible = false } })' >/dev/null 2>&1
  pkill -f '[o]rg.hypr.screensaver' 2>/dev/null
  exit 0
}

trap exit_screensaver SIGINT SIGTERM SIGHUP SIGQUIT

# Print the logo once, centered, with the rows fading from the accent (#798186) at the top
# to the foreground (#cacccc) at the bottom. Called again on SIGWINCH so a resized window
# (the compositor sizes it just after launch) re-centers the text.
draw() {
  local rows cols lines height width top left line row span r g b

  mapfile -t lines <"$text"
  read -r rows cols < <(stty size </dev/tty)

  height=${#lines[@]}
  width=0
  for line in "${lines[@]}"; do
    ((${#line} > width)) && width=${#line}
  done

  top=$(((rows - height) / 2 + 1))
  left=$(((cols - width) / 2 + 1))
  span=$((height > 1 ? height - 1 : 1))

  printf '\033[?25l\033[2J'

  for row in "${!lines[@]}"; do
    r=$((0x79 + (0xca - 0x79) * row / span))
    g=$((0x81 + (0xcc - 0x81) * row / span))
    b=$((0x86 + (0xcc - 0x86) * row / span))
    printf '\033[%d;%dH\033[38;2;%d;%d;%dm%s' "$((top + row))" "$left" "$r" "$g" "$b" "${lines[row]}"
  done
}

printf '\033]11;rgb:00/00/00\007' # black background
hyprctl eval 'hl.config({ cursor = { invisible = true } })' >/dev/null 2>&1

# The terminal starts at 80x24 and resizes once the compositor sizes the window;
# wait for that so the text is centered on the full screen
deadline=$((SECONDS + 2))
while ((SECONDS < deadline)) && [[ $(stty size 2>/dev/null) == "24 80" ]]; do
  sleep 0.02
done

draw
trap draw SIGWINCH

# A keypress exits; so does losing focus. A SIGWINCH redraw makes read return too,
# which is not a keypress, so the check below keeps the screensaver up.
while true; do
  if read -rsn1 -t 1 || ! screensaver_in_focus; then
    exit_screensaver
  fi
done
