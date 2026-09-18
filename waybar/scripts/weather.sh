#!/bin/bash

# Weather from wttr.in for the location saved in ~/.config/waybar/weather-location
# (automatic, from the IP address, when there's none)
# Usage: weather.sh            bar module output: temperature and condition icon, "Place · Temperature · Condition" on hover
#        weather.sh status     one line with the wind too, for a notification
#        weather.sh location   change the location in fuzzel (a city name, or "auto")

source "$(dirname "$(readlink -f "$0")")/common.sh"

LOCATION_FILE="$WAYBAR_DIR/weather-location"
SIGNAL=13

saved_location() {
  [[ -s $LOCATION_FILE ]] && head -n1 "$LOCATION_FILE"
}

# Tab-separated: place, temperature (°C), condition, wind (km/h), weather code, sunrise, sunset
# Usage: fetch [location]   (no location: wttr.in picks it from the IP address)
fetch() {
  local path
  path=$(jq -rn --arg location "${1:-}" '$location | @uri')

  curl -fsS --max-time 4 "https://wttr.in/$path?format=j1" 2>/dev/null | jq -er '
    [.nearest_area[0].areaName[0].value,
     (.current_condition[0] | .temp_C, (.weatherDesc[0].value | gsub("^\\s+|\\s+$"; "")), .windspeedKmph, .weatherCode),
     .weather[0].astronomy[0].sunrise, .weather[0].astronomy[0].sunset]
    | select(all(. != null and . != "")) | @tsv' 2>/dev/null
}

# Material Design weather icons from the Nerd Font, written as escapes so editors and tools can't drop them
ICON_SUNNY=$'\U000f0599'
ICON_SUNNY_ALERT=$'\U000f0f37'
ICON_NIGHT=$'\U000f0594'
ICON_PARTLY_CLOUDY=$'\U000f0595'
ICON_NIGHT_PARTLY_CLOUDY=$'\U000f0f31'
ICON_CLOUDY=$'\U000f0590'
ICON_FOG=$'\U000f0591'
ICON_PARTLY_RAINY=$'\U000f0f33'
ICON_RAINY=$'\U000f0597'
ICON_POURING=$'\U000f0596'
ICON_PARTLY_SNOWY=$'\U000f0f34'
ICON_SNOWY=$'\U000f0598'
ICON_SNOWY_HEAVY=$'\U000f0f36'
ICON_SNOWFLAKE_ALERT=$'\U000f0f29'
ICON_PARTLY_SNOWY_RAINY=$'\U000f0f35'
ICON_SNOWY_RAINY=$'\U000f067f'
ICON_HAIL=$'\U000f0592'
ICON_WINDY=$'\U000f059d'
ICON_PARTLY_LIGHTNING=$'\U000f0f32'
ICON_LIGHTNING=$'\U000f0593'
ICON_LIGHTNING_RAINY=$'\U000f067e'
ICON_THERMOMETER=$'\U000f050f'

# Condition icon for a wttr.in weather code: moon variants between sunset and sunrise, a sun alert
# from 32°C and a snowflake alert for heavy snow with thunder at -10°C and below
# Usage: icon <code> <temperature> <sunrise> <sunset>   (times like "06:52 AM")
icon() {
  local code=$1 temperature=$2 sunrise=$3 sunset=$4 night=false now sunrise_epoch sunset_epoch

  if [[ $sunrise =~ ^[0-9]{1,2}:[0-9]{2}\ [AP]M$ && $sunset =~ ^[0-9]{1,2}:[0-9]{2}\ [AP]M$ ]]; then
    now=$(date +%s)
    sunrise_epoch=$(date -d "today $sunrise" +%s 2>/dev/null || echo 0)
    sunset_epoch=$(date -d "today $sunset" +%s 2>/dev/null || echo 0)
    if ((sunrise_epoch > 0 && sunset_epoch > 0 && (now < sunrise_epoch || now >= sunset_epoch))); then
      night=true
    fi
  fi

  case $code in
  113) # Sunny / clear
    if [[ $night == "true" ]]; then
      echo "$ICON_NIGHT"
    elif ((temperature >= 32)); then
      echo "$ICON_SUNNY_ALERT"
    else
      echo "$ICON_SUNNY"
    fi
    ;;
  116) [[ $night == "true" ]] && echo "$ICON_NIGHT_PARTLY_CLOUDY" || echo "$ICON_PARTLY_CLOUDY" ;;
  119 | 122) echo "$ICON_CLOUDY" ;;                                    # Cloudy, overcast
  143 | 248 | 260) echo "$ICON_FOG" ;;                                # Mist, fog, freezing fog
  176 | 263 | 293 | 353) echo "$ICON_PARTLY_RAINY" ;;                # Patchy rain, patchy drizzle, light showers
  266 | 296 | 299 | 302) echo "$ICON_RAINY" ;;                       # Light drizzle, light to moderate rain
  305 | 308 | 356 | 359) echo "$ICON_POURING" ;;                     # Heavy and torrential rain
  179 | 323 | 368) echo "$ICON_PARTLY_SNOWY" ;;                      # Patchy snow, light snow showers
  326 | 329 | 332) echo "$ICON_SNOWY" ;;                             # Light to moderate snow
  230 | 335 | 338 | 371) echo "$ICON_SNOWY_HEAVY" ;;                 # Blizzard, heavy snow
  182 | 185) echo "$ICON_PARTLY_SNOWY_RAINY" ;;                      # Patchy sleet, patchy freezing drizzle
  281 | 284 | 311 | 314 | 317 | 320 | 362 | 365) echo "$ICON_SNOWY_RAINY" ;; # Freezing drizzle and rain, sleet
  350 | 374 | 377) echo "$ICON_HAIL" ;;                              # Ice pellets
  227) echo "$ICON_WINDY" ;;                                         # Blowing snow
  200) echo "$ICON_PARTLY_LIGHTNING" ;;                              # Thundery outbreaks possible
  386 | 389) echo "$ICON_LIGHTNING_RAINY" ;;                         # Rain with thunder
  392) echo "$ICON_LIGHTNING" ;;                                     # Light snow with thunder
  395) ((temperature <= -10)) && echo "$ICON_SNOWFLAKE_ALERT" || echo "$ICON_SNOWY_HEAVY" ;; # Heavy snow with thunder
  *) echo "$ICON_THERMOMETER" ;;
  esac
}

# Bar module: temperature and icon, or an empty "unavailable" module when offline
bar() {
  local location weather place temperature condition wind code sunrise sunset

  location=$(saved_location)
  if ! weather=$(fetch "$location"); then
    echo '{"text": "", "class": "unavailable"}'
    return
  fi
  IFS=$'\t' read -r place temperature condition wind code sunrise sunset <<<"$weather"

  # The tooltip is Pango markup, so escape the place (ex: an "&" in the name)
  jq -cn --arg text "${temperature}°C $(icon "$code" "$temperature" "$sunrise" "$sunset")" \
    --arg tooltip "${location:-$place}  ·  ${temperature}°C  ·  $condition" \
    '{text: $text, tooltip: ($tooltip | @html)}'
}

status() {
  local location weather place temperature condition wind code sunrise sunset

  location=$(saved_location)
  if ! weather=$(fetch "$location"); then
    echo "Weather unavailable"
    exit 1
  fi
  IFS=$'\t' read -r place temperature condition wind code sunrise sunset <<<"$weather"

  echo "$(icon "$code" "$temperature" "$sunrise" "$sunset")    ${location:-$place}  ·  ${temperature}°C  ·  $condition  ·  Wind $wind km/h"
}

# Ask for a city (checked against wttr.in before saving), or "auto" to go back to the IP address location
change_location() {
  local current new

  current=$(saved_location)
  new=$(fuzzel --dmenu --prompt-only "Weather location  " --placeholder "City or auto (now: ${current:-automatic})" 2>/dev/null) || exit 0

  # Trim surrounding spaces
  new="${new#"${new%%[![:space:]]*}"}"
  new="${new%"${new##*[![:space:]]}"}"
  [[ -z $new ]] && exit 0

  if [[ ${new,,} == "auto" || ${new,,} == "automatic" ]]; then
    rm -f "$LOCATION_FILE"
    notify-send -u low "Weather location: automatic" "Based on your IP address"
  elif fetch "$new" >/dev/null; then
    printf '%s\n' "$new" >"$LOCATION_FILE"
    notify-send -u low "Weather location: $new"
  else
    notify-send -u low "No weather for \"$new\"" "Check the spelling (or your connection) and try again"
    exit 1
  fi

  pkill -RTMIN+$SIGNAL waybar
}

case "${1:-}" in
"") bar ;;
status) status ;;
location) change_location ;;
*)
  echo "Usage: weather.sh [status|location]" >&2
  exit 1
  ;;
esac
