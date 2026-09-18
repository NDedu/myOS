-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- SUPER + / and SUPER + ALT + / change the scale of the focused monitor and
-- rewrite the two values below (scripts/monitor-scaling.sh).

local gdk_scale = 1
local monitor_scale = 1.33333

hl.env("GDK_SCALE", tostring(gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
