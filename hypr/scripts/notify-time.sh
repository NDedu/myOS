#!/bin/bash

# Show the date and time as a notification

notify-send -u low "    $(date +"%A %H:%M  ·  %d %B %Y  ·  Week %V")"
