#!/bin/bash

# Decode a QR code from a screen region and copy its content to the clipboard

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

# QR codes only: other barcode types false-positive on dense screen content
result=$(grim -g "$selection" - | zbarimg -q --raw -Sdisable -Sqrcode.enable - 2>/dev/null)

if [[ -z $result ]]; then
  notify-send -u critical "󰐲    No QR code found" "Select a region containing a QR code"
  exit 1
fi

# QR codes often carry secrets (2FA setup codes), so the value only goes to the
# clipboard, marked sensitive so clipboard history skips it
printf '%s' "$result" | wl-copy --sensitive
notify-send -u low "󰐲    QR code copied to clipboard"
