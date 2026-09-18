-- Waybar integration for a Hyprland Lua config (Hyprland 0.55+).
-- Loaded from ~/.config/hypr/hyprland.lua with:
--   dofile(os.getenv("HOME") .. "/.config/waybar/hyprland.lua")
-- (hyprland.conf in this folder is the same thing for the old hyprlang config)

local scripts = os.getenv("HOME") .. "/.config/waybar/scripts/"

-- Use the helpers from the main config when present (they record keybinding descriptions)
local bind = (o and o.bind) or function(keys, description, command)
  hl.bind(keys, hl.dsp.exec_cmd(command), { description = description })
end

-- Start the bar (goes through uwsm when the session uses it)
hl.on("hyprland.start", function()
  hl.exec_cmd(scripts .. "restart-waybar.sh")
end)

-- Float the terminals the bar opens (wifi, bluetooth, audio, btop, timezone, updates)
hl.window_rule({ match = { class = "^(org\\.waybar\\..*)$" }, float = true, center = true, size = { 875, 600 } })

-- Keybindings. xkbcommon names the comma keysym "comma"; "COMMA" does not match.
bind("SUPER + SHIFT + SPACE", "Toggle top bar", scripts .. "toggle-waybar.sh")
bind("SUPER + CTRL + I", "Toggle stay awake / idle lock and screensaver", scripts .. "toggle-idle.sh")
bind("SUPER + CTRL + comma", "Toggle silencing notifications", scripts .. "toggle-notification-silencing.sh")
