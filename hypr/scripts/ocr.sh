#!/bin/bash

# Select a screen region and copy its text (OCR with tesseract) to the clipboard
# Env: OCR_LANGS=eng+ron to recognize more languages (install tesseract-data-<lang>)

# Keep hyprpicker's frozen overlay up until grim has captured
cleanup_freeze() {
  [[ -n $PID ]] && kill "$PID" 2>/dev/null
}
trap cleanup_freeze EXIT

hyprpicker -r -z >/dev/null 2>&1 &
PID=$!
sleep .1
selection=$(slurp 2>/dev/null)

[[ -z $selection ]] && exit 0

text=$(grim -g "$selection" - | tesseract stdin stdout --oem 1 --psm 6 -l "${OCR_LANGS:-eng}" --dpi 300 -c preserve_interword_spaces=1 2>/dev/null) || exit 1
[[ -z $text ]] && exit 1

printf "%s" "$text" | wl-copy
notify-send -u low "󰴑    Copied text from selection to clipboard"
