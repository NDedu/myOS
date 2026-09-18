#!/bin/bash

# Reset config.jsonc and style.css to the defaults in defaults/, backing up any changes, then restart Waybar

source "$(dirname "$(readlink -f "$0")")/common.sh"

for file in config.jsonc style.css; do
  user_file="$WAYBAR_DIR/$file"
  default_file="$WAYBAR_DIR/defaults/$file"
  backup_file="$user_file.bak.$(date +%s)"

  if [[ ! -f $default_file ]]; then
    echo "Missing default $default_file"
    exit 1
  fi

  if [[ -f $user_file ]] && ! cmp -s "$user_file" "$default_file"; then
    cp -f "$user_file" "$backup_file"
    cp -f "$default_file" "$user_file"
    echo -e "\e[31mReplaced $user_file with the default.\nSaved backup as $backup_file.\n\n\e[32mChanges:\e[0m"
    diff "$user_file" "$backup_file"
  else
    cp -f "$default_file" "$user_file"
  fi
done

# The style imports colors.css, so make sure a theme is present
[[ -f $WAYBAR_DIR/colors.css ]] || cp "$WAYBAR_DIR/themes/vantablack.css" "$WAYBAR_DIR/colors.css"

"$SCRIPTS_DIR/restart-waybar.sh"
