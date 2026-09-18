-- Menus, notifications, toggles, captures and system actions.
-- SUPER + SHIFT + SPACE (bar), SUPER + CTRL + I (idle) and SUPER + CTRL + comma
-- (do not disturb) are bound in ~/.config/waybar/hyprland.lua.

-- Menus
o.bind("SUPER + SPACE", "Main menu", o.script("menu.sh"))
o.bind("SUPER + ALT + SPACE", "App launcher", o.waybar_script("launcher.sh"))
o.bind("SUPER + SHIFT + code:201", "Main menu", o.script("menu.sh"))
o.bind("SUPER + ESCAPE", "System menu", o.script("menu.sh", "system"))
o.bind("XF86PowerOff", "Power menu", o.script("menu.sh", "system"), { locked = true })
o.bind("SUPER + CTRL + C", "Capture menu", o.script("menu.sh", "capture"))
o.bind("SUPER + CTRL + O", "Toggle menu", o.script("menu.sh", "toggle"))
o.bind("SUPER + CTRL + E", "Emojis", o.script("emoji.sh"))
o.bind("SUPER + K", "Keybindings", o.script("keybindings.sh"))
o.bind("SUPER + CTRL + Q", "Calculator", o.launch("gnome-calculator"))
o.bind("XF86Calculator", "Calculator", o.launch("gnome-calculator"))

-- Aesthetics
o.bind("SUPER + CTRL + SPACE", "Reload wallpaper", o.script("wallpaper-reload.sh"))
o.bind("SUPER + BACKSPACE", "Toggle window transparency", o.script("window-transparency-toggle.sh"))
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", o.script("toggle-flag.sh", "window-no-gaps"))
o.bind("SUPER + CTRL + BACKSPACE", "Toggle single-window square aspect", o.script("toggle-flag.sh", "single-window-aspect-ratio"))

-- Notifications (mako). xkbcommon names the comma keysym "comma"; "COMMA" does not match.
o.bind("SUPER + comma", "Dismiss last notification", "makoctl dismiss")
o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", "makoctl dismiss --all")
o.bind("SUPER + ALT + comma", "Invoke last notification", "makoctl invoke")
o.bind("SUPER + SHIFT + ALT + comma", "Restore last notification", "makoctl restore")

-- Toggles
o.bind("SUPER + CTRL + N", "Toggle nightlight", o.script("toggle-nightlight.sh"))
o.bind("SUPER + CTRL + Delete", "Toggle laptop display", o.script("monitor-internal.sh", "toggle"))
o.bind("SUPER + CTRL + ALT + Delete", "Toggle laptop display mirroring", o.script("monitor-mirror.sh", "toggle"))
o.bind("switch:on:Lid Switch", nil, o.script("lid-close.sh"), { locked = true })
o.bind("switch:off:Lid Switch", nil, o.script("monitor-internal.sh", "on"), { locked = true })

-- Captures
o.bind("PRINT", "Screenshot", o.script("screenshot.sh"))
o.bind("ALT + PRINT", "Screenrecording", o.script("menu.sh", "screenrecord"))
o.bind("SUPER + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.bind("SUPER + CTRL + PRINT", "Extract text (OCR) from screenshot", o.script("ocr.sh"))

-- Keyboard control for the screenshot region picker (scripts/capture-region.sh).
-- The binds live exactly as long as a selection layer is on screen (slurp opens
-- one per monitor), so they cannot leak or get stuck. Each handle is removed
-- individually, since unbinding by key would also drop the normal binds on those keys.
local selection_layers = 0
local selection_binds = {}

local function capture_region(args)
  return hl.dsp.exec_cmd(o.script("capture-region.sh", args))
end

hl.on("layer.opened", function(layer)
  if layer.namespace == "selection" then
    selection_layers = selection_layers + 1
    if selection_layers == 1 then
      selection_binds = {
        hl.bind("RETURN", capture_region("--take-window"), { description = "Capture highlighted window" }),
        hl.bind("CTRL + RETURN", capture_region("--take-fullscreen"), { description = "Capture entire screen" }),
        hl.bind("TAB", capture_region("--select-window next"), { description = "Select next window to capture" }),
        hl.bind("CTRL + TAB", capture_region("--select-window prev"), { description = "Select previous window to capture" }),
      }
      for _, direction in ipairs({ "left", "right", "up", "down" }) do
        table.insert(selection_binds, hl.bind(direction:upper(), capture_region("--select-window " .. direction), { description = "Select window to capture" }))
      end
    end
  end
end)

hl.on("layer.closed", function(layer)
  if layer.namespace == "selection" and selection_layers > 0 then
    selection_layers = selection_layers - 1
    if selection_layers == 0 then
      for _, keybind in ipairs(selection_binds) do
        keybind:unbind()
      end
      selection_binds = {}
    end
  end
end)

-- Reminders
o.bind("SUPER + CTRL + R", "Set reminder", o.script("reminder.sh", "set"))
o.bind("SUPER + CTRL + ALT + R", "Show reminders", o.script("reminder.sh", "show"))
o.bind("SUPER + SHIFT + CTRL + R", "Clear reminders", o.script("reminder.sh", "clear"))

-- Information without the bar
o.bind("SUPER + CTRL + ALT + T", "Show time", o.script("notify-time.sh"))
o.bind("SUPER + CTRL + ALT + B", "Show battery remaining", "notify-send -u low \"$(" .. o.waybar_script("battery-status.sh") .. ")\"")
o.bind("SUPER + CTRL + ALT + W", "Show weather", "notify-send -u low \"$(" .. o.waybar_script("weather.sh", "status") .. ")\"")

-- Control panels
o.bind("SUPER + CTRL + A", "Audio", o.waybar_script("launch-audio.sh"))
o.bind("SUPER + CTRL + B", "Bluetooth", o.waybar_script("launch-bluetooth.sh"))
o.bind("SUPER + CTRL + W", "Network", o.waybar_script("launch-wifi.sh"))
o.bind("SUPER + CTRL + P", "Power profile", o.waybar_script("power-profile-menu.sh"))
o.bind("SUPER + CTRL + T", "Activity", o.waybar_script("launch-or-focus-tui.sh", "btop"))

-- Zoom
o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)

o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

-- Lock
o.bind("SUPER + CTRL + L", "Lock system", o.script("lock.sh"))
