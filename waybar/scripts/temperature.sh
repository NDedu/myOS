#!/bin/bash

# CPU temperature for the bar: thermometer icon filling up every 20°C, a fire icon at 80°C and above.
# Reads the CPU sensor (AMD k10temp/zenpower, Intel coretemp, ARM cpu_thermal) looked up by name, because
# hwmon numbers change between boots, and falls back to the first thermal zone.

CRITICAL=80
ICONS=($'\uf2cb' $'\uf2ca' $'\uf2c9' $'\uf2c7')
FIRE=$'\U0001f525'

sensor() {
  local hwmon
  for hwmon in /sys/class/hwmon/hwmon*; do
    case $(<"$hwmon/name") in
    k10temp | zenpower | coretemp | cpu_thermal)
      if [[ -r $hwmon/temp1_input ]]; then
        echo "$hwmon/temp1_input"
        return
      fi
      ;;
    esac
  done
  [[ -r /sys/class/thermal/thermal_zone0/temp ]] && echo /sys/class/thermal/thermal_zone0/temp
}

input=$(sensor)
if [[ -z $input ]]; then
  echo '{"text": ""}'
  exit
fi

celsius=$(($(<"$input") / 1000))

if ((celsius >= CRITICAL)); then
  echo "{\"text\": \"$FIRE ${celsius}°C\", \"class\": \"critical\"}"
else
  index=$((celsius * ${#ICONS[@]} / CRITICAL))
  echo "{\"text\": \"${ICONS[index]} ${celsius}°C\"}"
fi
