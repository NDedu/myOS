#!/bin/bash

# Returns a formatted battery status string with percentage and power draw/charge.

battery_info=$(upower -i $(upower -e | grep BAT))

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

if [[ $state == "charging" ]]; then
    echo "󰁹    Battery ${percentage}%  ·  ${time_remaining} to full  ·   ${power_rate}W / ${capacity}Wh"
else
    echo "󰁹    Battery ${percentage}%  ·  ${time_remaining} left  ·   ${power_rate}W / ${capacity}Wh"
fi
