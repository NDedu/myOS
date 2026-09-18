#!/bin/bash

# Select and set the system timezone (needs gum or fzf), then restart Waybar so the clock picks it up

source "$(dirname "$(readlink -f "$0")")/common.sh"

if command -v gum >/dev/null; then
  timezone=$(timedatectl list-timezones | gum filter --height 20 --header "Set timezone") || exit 1
else
  timezone=$(timedatectl list-timezones | fzf --height 20 --header "Set timezone") || exit 1
fi

sudo timedatectl set-timezone "$timezone"
echo "Timezone is now set to $timezone"
"$SCRIPTS_DIR/restart-waybar.sh"
