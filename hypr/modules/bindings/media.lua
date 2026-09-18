-- Volume, brightness, keyboard backlight, touchpad and media keys (with SwayOSD).

local locked = { locked = true }
local locked_repeat = { locked = true, repeating = true }

o.bind("XF86AudioRaiseVolume", "Volume up", o.script("osd.sh", "--output-volume raise"), locked_repeat)
o.bind("XF86AudioLowerVolume", "Volume down", o.script("osd.sh", "--output-volume lower"), locked_repeat)
o.bind("XF86AudioMute", "Mute", o.script("osd.sh", "--output-volume mute-toggle"), locked)
o.bind("XF86AudioMicMute", "Mute microphone", o.script("audio-input-mute.sh"), locked)
o.bind("XF86MonBrightnessUp", "Brightness up", o.script("brightness-display.sh", "+5%"), locked_repeat)
o.bind("XF86MonBrightnessDown", "Brightness down", o.script("brightness-display.sh", "5%-"), locked_repeat)
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", o.script("brightness-display.sh", "100%"), locked_repeat)
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", o.script("brightness-display.sh", "1%"), locked_repeat)
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", o.script("brightness-keyboard.sh", "up"), locked_repeat)
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", o.script("brightness-keyboard.sh", "down"), locked_repeat)
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", o.script("brightness-keyboard.sh", "cycle"), locked)
o.bind("XF86TouchpadToggle", "Toggle touchpad", o.script("toggle-touchpad.sh"), locked)
o.bind("XF86TouchpadOn", "Enable touchpad", o.script("toggle-touchpad.sh", "on"), locked)
o.bind("XF86TouchpadOff", "Disable touchpad", o.script("toggle-touchpad.sh", "off"), locked)

-- Precise volume and brightness controls.
o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", o.script("osd.sh", "--output-volume +1"), locked_repeat)
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", o.script("osd.sh", "--output-volume -1"), locked_repeat)
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", o.script("brightness-display.sh", "+1%"), locked_repeat)
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", o.script("brightness-display.sh", "1%-"), locked_repeat)

-- Media controls (playerctl).
o.bind("XF86AudioNext", "Next track", o.script("osd.sh", "--playerctl next"), locked)
o.bind("ALT + XF86AudioPlay", "Next track", o.script("osd.sh", "--playerctl next"), locked)
o.bind("XF86AudioPause", "Pause", o.script("osd.sh", "--playerctl play-pause"), locked)
o.bind("XF86AudioPlay", "Play", o.script("osd.sh", "--playerctl play-pause"), locked)
o.bind("XF86AudioPrev", "Previous track", o.script("osd.sh", "--playerctl previous"), locked)
o.bind("ALT + SHIFT + XF86AudioPlay", "Previous track", o.script("osd.sh", "--playerctl previous"), locked)
o.bind("XF86Eject", "Eject media", "eject", locked)

o.bind("SHIFT + XF86AudioMute", "Switch audio output", o.script("audio-output-switch.sh"), locked)
