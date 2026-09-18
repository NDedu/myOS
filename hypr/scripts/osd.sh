#!/bin/bash

# swayosd-client on the focused monitor (volume, media keys, custom messages)
# Usage: osd.sh <swayosd-client args...>   e.g. osd.sh --output-volume raise

source "$(dirname "$(readlink -f "$0")")/common.sh"

exec swayosd-client --monitor "$(focused_monitor)" "$@"
