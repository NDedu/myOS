#!/bin/bash

# Update system packages in a floating terminal, then refresh the update icon

source "$(dirname "$(readlink -f "$0")")/common.sh"

"$SCRIPTS_DIR/floating-terminal.sh" "sudo pacman -Syu"
pkill -RTMIN+7 waybar
