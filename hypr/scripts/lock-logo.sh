#!/bin/bash

# The logo on the lock screen (hyprlock.conf): ../screensaver.txt as Pango markup, with the rows
# fading from the accent (#798186) at the top to the foreground (#cacccc), like the screensaver.
# Rows overlap a little (line_height), or thin gaps show between the blocks.

logo="$(dirname "$(dirname "$(readlink -f "$0")")")/screensaver.txt"

awk '
  { gsub(/&/, "\\&amp;"); gsub(/</, "\\&lt;"); lines[NR] = $0 }
  END {
    span = NR > 1 ? NR - 1 : 1
    printf "<span line_height=\"0.95\">"
    for (row = 1; row <= NR; row++)
      printf "<span foreground=\"#%02x%02x%02x\">%s</span>%s", 121 + 81 * (row - 1) / span, 129 + 75 * (row - 1) / span, 134 + 70 * (row - 1) / span, lines[row], row < NR ? "\n" : ""
    printf "</span>"
  }' "$logo"
