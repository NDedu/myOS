-- Window and layer rules.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window(".*", { suppress_event = "maximize" })

-- Tag all windows for default opacity (apps below can opt out with -default-opacity).
o.window(".*", { tag = "+default-opacity" })

-- Fix some dragging issues with XWayland.
o.window({ class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, { no_focus = true })

-- Terminals ------------------------------------------------------------------

-- The terminal tag lets the universal copy/paste bindings send the right keys.
-- org.hypr.screensaver is the screensaver, org.waybar.* are the terminals the bar opens.
o.window("(Alacritty|kitty|com.mitchellh.ghostty|foot|org\\.codeberg\\.dnkl\\.foot|wezterm|org\\.hypr\\..*|org\\.waybar\\..*)", { tag = "+terminal" })

-- Floating windows -----------------------------------------------------------

o.window({ tag = "floating-window" }, { float = true })
o.window({ tag = "floating-window" }, { center = true })
o.window({ tag = "floating-window" }, { size = { 875, 600 } })

o.window("(org.gnome.Evince|org.gnome.NautilusPreviewer|About|imv|mpv|org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor)", { tag = "+floating-window" })

-- File pickers, screen share prompts and other portal dialogs.
o.window("xdg-desktop-portal-gtk", { tag = "+floating-window" })
o.window("(xdg-desktop-portal-kde|org.freedesktop.impl.portal.desktop.kde)", { tag = "+floating-window" })
o.window({
  class = "(sublime_text|DesktopEditors|org.gnome.Nautilus|org.kde.dolphin|org.kde.kdialog)",
  title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
}, { tag = "+floating-window" })

-- Dolphin's own dialogs (copy progress, properties, conflicts).
o.window({ class = "org.kde.dolphin", title = "^(Properties for .*|Copying.*|Moving.*|Deleting.*|File Already Exists|Folder Already Exists|Progress Dialog.*)$" }, { tag = "+floating-window" })

-- Polkit and keyring password prompts.
o.window("(polkit-gnome-authentication-agent-1|hyprpolkitagent|gcr-prompter)", { float = true, center = true, pin = true })

o.window("(gnome-calculator|org.gnome.Calculator|qalculate-gtk)", { float = true })

-- Screenshot annotation editor.
o.window("com.gabm.satty", { float = true, center = true })

-- Screensaver, shown fullscreen on every monitor.
o.window("org.hypr.screensaver", { fullscreen = true, float = true, animation = "slide" })

-- Popped-out window rounding (SUPER + O).
o.window({ tag = "pop" }, { rounding = 8 })

-- Prevent idle while open.
o.window({ tag = "noidle" }, { idle_inhibit = "always" })

-- Browsers ---------------------------------------------------------------------

o.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser" })
o.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser" })
o.window({ tag = "chromium-based-browser" }, { tag = "-default-opacity", tile = true, opacity = "1.0 0.985" })
o.window({ tag = "firefox-based-browser" }, { tag = "-default-opacity", opacity = "1.0 0.985" })

-- Hide screen sharing notification windows.
o.window({ title = ".*is sharing.*" }, { workspace = "special silent" })

-- Picture-in-picture overlays.
o.window({ title = "(Picture.?in.?[Pp]icture)" }, { tag = "+pip" })
o.window({ tag = "pip" }, {
  tag = "-default-opacity",
  float = true,
  pin = true,
  size = { 600, 338 },
  keep_aspect_ratio = true,
  border_size = 0,
  opacity = "1 1",
  move = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

-- Apps -------------------------------------------------------------------------

-- No transparency on media windows.
o.window("^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer|org.kde.gwenview|org.kde.okular)$", { tag = "-default-opacity" })
o.window("^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer|org.kde.gwenview|org.kde.okular)$", { opacity = "1 1" })

o.window("^(Bitwarden)$", { no_screen_share = true, tag = "+floating-window" })
o.window("^(jetbrains-.*)$", { no_follow_mouse = true })
o.window("(Share|localsend)", { float = true, center = true })
o.window("localsend", { size = { 1100, 700 } })
o.window("org.telegram.desktop", { focus_on_activate = false })
o.window("qemu", { tag = "-default-opacity", opacity = "1 1" })

o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window("steam.*", { tag = "-default-opacity", opacity = "1 1" })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })
o.window("com.moonlight_stream.Moonlight", { fullscreen = true, idle_inhibit = "fullscreen" })
o.window("com.libretro.RetroArch", { fullscreen = true, tag = "-default-opacity", opacity = "1 1", idle_inhibit = "fullscreen" })
o.window("GeForceNOW", { idle_inhibit = "fullscreen" })

-- Layers -------------------------------------------------------------------------

-- Screenshot region picker: no fade and no border flash.
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })
-- Launcher (fuzzel) and OSD pop instantly.
hl.layer_rule({ match = { namespace = "^(launcher|swayosd)$" }, no_anim = true, animation = "none" })

-- Apply default opacity after apps have had a chance to opt out.
o.window({ tag = "default-opacity" }, { opacity = "0.985 0.96" })
