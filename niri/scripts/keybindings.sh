#!/bin/bash

# Searchable list of the niri keys (Super + K, Menu > Keybindings), read from ../config.kdl. A key's text is its
# hotkey-overlay-title, else the comment after it, else its action (niri version of ~/.config/hypr/scripts/keybindings.sh)

config="$(dirname "$(dirname "$(readlink -f "$0")")")/config.kdl"

awk '
  BEGIN {
    split("Comma , Period . Slash / Minus - Equal = BracketLeft [ BracketRight ] Return RETURN Space SPACE " \
          "BackSpace BACKSPACE Escape ESCAPE Tab TAB Print PRINT Delete DELETE Home HOME End END " \
          "Page_Up PAGE_UP Page_Down PAGE_DOWN Left LEFT Right RIGHT Up UP Down DOWN " \
          "WheelScrollDown SCROLL_DOWN WheelScrollUp SCROLL_UP WheelScrollLeft SCROLL_LEFT WheelScrollRight SCROLL_RIGHT", pairs, " ")
    for (i = 1; i < length(pairs); i += 2) names[pairs[i]] = pairs[i + 1]
  }

  /^binds \{/ { inside = 1; next }
  inside && /^\}/ { exit }
  !inside || /^[[:space:]]*(\/\/|$)/ { next }

  match($0, /^[[:space:]]*([A-Za-z0-9_+]+)[[:space:]]+([^{]*)\{(.*)\}[[:space:]]*(\/\/[[:space:]]*(.*))?$/, m) {
    keys = m[1]; props = m[2]; action = m[3]; comment = m[5]

    if (match(props, /hotkey-overlay-title="([^"]*)"/, t)) text = t[1]
    else if (comment != "") text = comment
    else {
      # "move-window-to-workspace \"1\" focus=false;" -> "Move window to workspace 1 (stay)"
      gsub(/;[[:space:]]*$/, "", action); gsub(/^[[:space:]]+/, "", action)
      gsub(/"/, "", action); sub(/ focus=false/, " (stay)", action)
      split(action, words, " ")
      name = words[1]; gsub(/-/, " ", name)
      text = toupper(substr(name, 1, 1)) substr(name, 2) substr(action, length(words[1]) + 1)
    }

    # "Mod+Shift+Comma" -> "SUPER + SHIFT + ,"
    n = split(keys, part, "+")
    label = ""
    for (i = 1; i <= n; i++) {
      p = part[i]
      if (i < n) p = (p == "Mod" || p == "Super") ? "SUPER" : toupper(p)
      else if (p in names) { p = names[p]; gsub(/_/, " ", p) }
      else if (length(p) == 1) p = toupper(p)
      label = label (i > 1 ? " + " : "") p
    }
    printf "%-38s %s\n", label, text
  }
' "$config" 2>/dev/null |
  fuzzel --dmenu --width 90 --lines 20 --prompt "Keybindings  " --placeholder "Search keybindings..." >/dev/null
