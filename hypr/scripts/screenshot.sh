#!/bin/bash

# Take a screenshot: saved to ~/Pictures and copied to the clipboard; click the notification
# (or SUPER + ALT + comma) to annotate it in satty. Press PRINT again to cancel the picker.
#
# While picking: drag a region, click a window, RETURN takes the highlighted window,
# CTRL + RETURN the whole screen, TAB / arrows move between windows.
#
# Usage: screenshot.sh [smart|region|windows|fullscreen] [slurp|copy|save] [--editor=<command>]
# Env: SCREENSHOT_DIR (default XDG pictures dir), SCREENSHOT_EDITOR (default satty)

source "$(dirname "$(readlink -f "$0")")/common.sh"

[[ -f ~/.config/user-dirs.dirs ]] && source ~/.config/user-dirs.dirs
OUTPUT_DIR="${SCREENSHOT_DIR:-${XDG_PICTURES_DIR:-$HOME/Pictures}}"

if [[ ! -d $OUTPUT_DIR ]]; then
  mkdir -p "$OUTPUT_DIR"
  notify-send -u low "Created screenshot directory: $OUTPUT_DIR" -t 2000
fi

pkill slurp && exit 0

SCREENSHOT_EDITOR="${SCREENSHOT_EDITOR:-}"

# Parse --editor flag from any position
ARGS=()
for arg in "$@"; do
  if [[ $arg == --editor=* ]]; then
    SCREENSHOT_EDITOR="${arg#--editor=}"
  else
    ARGS+=("$arg")
  fi
done
set -- "${ARGS[@]}"

MODE="${1:-smart}"
PROCESSING="${2:-slurp}"

# Annotate in place: saving writes back to the same file, Enter copies to the clipboard
open_editor() {
  local file="$1"

  if [[ -n $SCREENSHOT_EDITOR ]]; then
    $SCREENSHOT_EDITOR "$file"
  elif command -v satty >/dev/null; then
    satty --filename "$file" --output-filename "$file" --actions-on-enter save-to-clipboard --save-after-copy --copy-command wl-copy
  else
    xdg-open "$file"
  fi
}

# The picker leaves the screen freeze running (PID on its first output line)
# so grim captures the frozen overlay rather than live content shifting
# during teardown.
#
# Software-composited cursors (Hyprland's fallback on GPUs without working
# hardware cursors) are baked into the frames grim captures, so force
# hardware cursors until after grim runs and restore the setting on exit.
NO_HW_CURSORS=$(hyprctl getoption cursor:no_hardware_cursors -j | jq '.int')

set_no_hw_cursors() {
  hyprctl eval "hl.config({ cursor = { no_hardware_cursors = $1 } })" &>/dev/null
}

cleanup() {
  [[ -n $FREEZE_PID ]] && kill "$FREEZE_PID" 2>/dev/null
  set_no_hw_cursors "$NO_HW_CURSORS"
}
trap cleanup EXIT

set_no_hw_cursors 0
{
  read -r FREEZE_PID
  read -r SELECTION
} < <("$SCRIPTS_DIR/capture-region.sh" "$MODE" --keep-freeze)

[[ -z $SELECTION ]] && exit 0

FILENAME="screenshot-$(date +'%Y-%m-%d_%H-%M-%S').png"
FILEPATH="$OUTPUT_DIR/$FILENAME"

case "$PROCESSING" in
slurp)
  grim -g "$SELECTION" "$FILEPATH" || exit 1
  echo "$FILEPATH"
  wl-copy --type image/png <"$FILEPATH"

  # Waits for a click in the background, so the freeze and cursor setting are restored right away
  (
    action=$(notify-send "Screenshot saved to clipboard and file" "Edit with Super + Alt + , (or click this)" \
      -t 10000 -i "$FILEPATH" -A "default=Edit")
    [[ $action == "default" ]] && open_editor "$FILEPATH"
  ) >/dev/null 2>&1 &
  ;;
copy)
  grim -g "$SELECTION" - | wl-copy --type image/png
  ;;
save)
  grim -g "$SELECTION" "$FILEPATH" || exit 1
  echo "$FILEPATH"
  ;;
esac
