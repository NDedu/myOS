-- Runtime toggles written by scripts into ~/.local/state/hypr/:
--   toggles/*.lua          window gaps, square aspect, laptop display off, mirroring
--   workspace-layouts/*.lua per-workspace dwindle/scrolling choice (SUPER + L)
--   touchpad-disabled-name  touchpad disabled with XF86TouchpadToggle
-- Loaded last so they override the rest of the config.

local function load_dir(dir)
  local handle = io.popen("find " .. o.shell_quote(dir) .. " -maxdepth 1 -type f -name '*.lua' 2>/dev/null | sort")
  if not handle then
    return
  end

  for path in handle:lines() do
    dofile(path)
  end

  handle:close()
end

load_dir(o.state .. "toggles")
load_dir(o.state .. "workspace-layouts")

-- The touchpad name is stored as plain data (it comes from the USB descriptor)
-- and must never be loaded as code.
local file = io.open(o.state .. "touchpad-disabled-name", "r")
if file then
  local name = file:read("*l")
  file:close()

  if name and name ~= "" then
    hl.device({ name = name, enabled = false })
  end
end
