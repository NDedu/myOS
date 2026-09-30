#!/bin/bash

# Returns a formatted battery status string with percentage and power draw/charge.

battery=$(upower -e | grep -m1 'battery_BAT')
if [[ -z $battery ]]; then
    echo "No battery"
    exit 0
fi
battery_info=$(upower -i "$battery")

percentage=$(echo "$battery_info" | awk '/percentage/ {
    print int($2)
    exit
}')

power_rate=$(echo "$battery_info" | awk '/energy-rate/ {
    rounded = sprintf("%.1f", $2)
    sub(/\.0$/, "", rounded)
    print rounded
    exit
}')

state=$(echo "$battery_info" | awk '/state/ { print $2; exit }')
time_remaining=$(echo "$battery_info" | awk '/time to (empty|full)/ {
    value = $4
    unit = $5
    if (unit ~ /^minute/) {
        printf "%dm", int(value)
    } else {
        hours = int(value)
        minutes = int((value - hours) * 60)
        if (minutes > 0) {
            printf "%dh %dm", hours, minutes
        } else {
            printf "%dh", hours
        }
    }
    exit
}')
capacity=$(echo "$battery_info" | awk '/energy-full:/ {
    printf "%d", $2
    exit
}')

# No time estimate when fully charged, held at a charge limit (pending-charge), or just (un)plugged
if [[ -z $time_remaining ]]; then
    echo "󰁹    Battery ${percentage}%  ·  ${state//-/ }  ·  ${capacity}Wh"
    exit 0
fi

if [[ $state == "charging" ]]; then
    echo "󰁹    Battery ${percentage}%  ·  ${time_remaining} to full  ·   ${power_rate}W / ${capacity}Wh"
else
    echo "󰁹    Battery ${percentage}%  ·  ${time_remaining} left  ·   ${power_rate}W / ${capacity}Wh"
fi
