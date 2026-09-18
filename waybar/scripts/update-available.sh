#!/bin/bash

# Show the update icon when package updates are available (needs checkupdates from pacman-contrib)
# Exiting non-zero hides the module.

command -v checkupdates >/dev/null || exit 1

count=$(checkupdates 2>/dev/null | wc -l)

if ((count > 0)); then
  echo "Package updates available: $count"
else
  exit 1
fi
