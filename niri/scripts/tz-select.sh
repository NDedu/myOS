#!/bin/bash

# Select and set the system timezone, then restart the bar so the clock picks it up
# (niri version of ~/.config/waybar/scripts/tz-select.sh, which restarts the Hyprland bar)

if command -v gum >/dev/null; then
  timezone=$(timedatectl list-timezones | gum filter --height 20 --header "Set timezone") || exit 1
else
  timezone=$(timedatectl list-timezones | fzf --height 20 --header "Set timezone") || exit 1
fi

sudo timedatectl set-timezone "$timezone"
echo "Timezone is now set to $timezone"
"$(dirname "$(readlink -f "$0")")/waybar.sh"
