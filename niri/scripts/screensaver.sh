#!/bin/bash

# Screensaver in niri: ~/.config/hypr/screensaver.txt centered on a black screen in the solitude colors, static,
# until a key is pressed or the window loses focus (niri version of ~/.config/hypr/scripts/screensaver.sh).
# Runs inside the terminal opened by launch-screensaver.sh. niri hides the cursor by itself after a minute
# without mouse movement (cursor in ../config.kdl); it has no command to hide it right away.

export LC_ALL=${LC_ALL:-C.UTF-8} # count block characters as one character each

text="$HOME/.config/hypr/screensaver.txt"

screensaver_in_focus() {
  niri msg --json focused-window | jq -e '.app_id == "org.niri.screensaver"' >/dev/null 2>&1
}

exit_screensaver() {
  printf '\033[?25h'
  pkill -f -- '--class=[o]rg.niri.screensaver' 2>/dev/null
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

# The terminal starts at 80x24 and resizes once niri sizes the window;
# wait for that so the text is centered on the full screen
deadline=$((SECONDS + 2))
while ((SECONDS < deadline)) && [[ $(stty size 2>/dev/null) == "24 80" ]]; do
  sleep 0.02
done

draw

# A resize (niri makes the window fullscreen after it opens) only sets a flag. Redrawing from inside the
# trap starts subshells, which stops bash's read -t from ever timing out, and the focus check with it
resized=false
trap 'resized=true' SIGWINCH

# A keypress exits; so does losing focus
while true; do
  read -rsn1 -t 1 && exit_screensaver

  if [[ $resized == true ]]; then
    resized=false
    draw
  fi

  screensaver_in_focus || exit_screensaver
done
