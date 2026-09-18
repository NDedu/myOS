#!/bin/bash

# Set the Waybar colors to one of the themes in themes/ (lists them when called without a name)
# Usage: theme-set.sh [theme-name]

source "$(dirname "$(readlink -f "$0")")/common.sh"

if [[ -z $1 ]]; then
  basename -s .css "$WAYBAR_DIR"/themes/*.css
  exit 0
fi

theme=${1,,}
theme_file="$WAYBAR_DIR/themes/${theme// /-}.css"

if [[ ! -f $theme_file ]]; then
  echo "Unknown theme: $1"
  exit 1
fi

cp -f "$theme_file" "$WAYBAR_DIR/colors.css"

# Waybar only watches style.css itself, so restart to pick up the new colors
if pgrep -x waybar >/dev/null; then
  "$SCRIPTS_DIR/restart-waybar.sh"
fi
