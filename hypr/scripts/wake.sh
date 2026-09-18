#!/bin/bash

# Turn displays back on and restore the keyboard backlight (after unlock and resume)

source "$(dirname "$(readlink -f "$0")")/common.sh"

"$SCRIPTS_DIR/brightness-display.sh" on
"$SCRIPTS_DIR/brightness-keyboard.sh" restore 2>/dev/null
exit 0
