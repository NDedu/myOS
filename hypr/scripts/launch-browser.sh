#!/bin/bash

# Launch the default browser (xdg-settings), with --private for a private window
# Usage: launch-browser.sh [--private] [url]

source "$(dirname "$(readlink -f "$0")")/common.sh"

desktop_file=$(xdg-settings get default-web-browser 2>/dev/null)
[[ -z $desktop_file ]] && desktop_file=$(xdg-mime query default x-scheme-handler/https)
browser=$(sed -n 's/^Exec=\([^ ]*\).*/\1/p' {~/.local,/usr}/share/applications/"$desktop_file" 2>/dev/null | head -1)
browser=${browser:-chromium}

if "$browser" --help 2>/dev/null | grep -q MOZ_LOG; then
  private_flag="--private-window"
elif [[ $browser =~ edge ]]; then
  private_flag="--inprivate"
else
  private_flag="--incognito"
fi

exec setsid "${APP[@]}" "$browser" "${@/--private/$private_flag}"
