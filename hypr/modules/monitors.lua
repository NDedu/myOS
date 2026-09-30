-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- monitor_scale is the default for every monitor. SUPER + / and SUPER + ALT + / change the
-- focused monitor's scale and remember it for that monitor (scripts/monitor-scaling.sh).
-- GDK_SCALE takes whole numbers only and only sizes X11 GTK apps, so it stays one value.

local gdk_scale = 1
local monitor_scale = 1.33333

hl.env("GDK_SCALE", tostring(gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = monitor_scale })

-- Remembered scales: one "output<tab>scale" line per monitor in ~/.local/state/hypr/monitor-scales.
-- Outputs are "desc:<description>" from the monitor's EDID, so the file is read as data, never run.
local file = io.open(o.state .. "monitor-scales", "r")
if file then
  for line in file:lines() do
    local output, scale = line:match("^([^\t]+)\t([%d.]+)$")
    if output and tonumber(scale) then
      hl.monitor({ output = output, mode = "preferred", position = "auto", scale = tonumber(scale) })
    end
  end
  file:close()
end

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
