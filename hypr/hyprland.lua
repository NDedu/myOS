-- Hyprland config (solitude theme).
-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/
--
-- Layout:
--   modules/helpers.lua     o.bind / o.window / o.launch helpers used everywhere
--   modules/envs.lua        environment variables
--   modules/monitors.lua    monitors and scaling
--   modules/input.lua       keyboard, mouse, touchpad, gestures
--   modules/looknfeel.lua   gaps, borders, animations, layouts
--   modules/theme.lua       solitude colors (border gradient, rounding)
--   modules/windows.lua     window and layer rules
--   modules/autostart.lua   services started with Hyprland
--   modules/bindings/*.lua  keybindings
--   modules/toggles.lua     runtime toggles (gaps, laptop display, ...)
--   scripts/                every script the config calls

local home = os.getenv("HOME")

-- Reloads re-run this file in the same Lua state, so drop cached modules first
-- or `require` would skip files that changed.
for module in pairs(package.loaded) do
  if module:sub(1, 5) == "hypr." then
    package.loaded[module] = nil
  end
end

-- Modules resolve from ~/.config, so "hypr.modules.envs" is ~/.config/hypr/modules/envs.lua
package.path = home .. "/.config/?.lua;" .. package.path

require("hypr.modules.helpers")
require("hypr.modules.envs")
require("hypr.modules.monitors")
require("hypr.modules.input")
require("hypr.modules.looknfeel")
require("hypr.modules.theme")
require("hypr.modules.windows")
require("hypr.modules.autostart")

require("hypr.modules.bindings.applications")
require("hypr.modules.bindings.tiling")
require("hypr.modules.bindings.media")
require("hypr.modules.bindings.clipboard")
require("hypr.modules.bindings.utilities")

-- Waybar: starts the bar, floats the terminals it opens, adds its toggle keys
local waybar = home .. "/.config/waybar/hyprland.lua"
if o.file_exists(waybar) then
  dofile(waybar)
end

-- Runtime toggles must load last so they override everything above.
require("hypr.modules.toggles")

-- Writes the keybinding list shown by SUPER + K.
o.write_keybindings_cache()

-- Add any other personal configuration below.
-- o.window("qemu", { workspace = "5" })
