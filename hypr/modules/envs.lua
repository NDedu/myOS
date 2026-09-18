-- Environment variables.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor size.
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force all apps to use Wayland.
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
-- Qt apps (Dolphin) take their palette and icons from the GTK settings (Adwaita-dark + Papirus-Dark).
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
-- Dolphin's "Open With" list needs a menu file outside Plasma (archlinux-xdg-menu)
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc).
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Use XCompose file (Right Alt is the compose key, see input.lua).
hl.env("XCOMPOSEFILE", o.home .. "/.XCompose")

-- Style gum prompts (used by some scripts) with the solitude colors.
hl.env("GUM_CONFIRM_PROMPT_FOREGROUND", "#798186")
hl.env("GUM_CONFIRM_SELECTED_FOREGROUND", "#a5aeb4")
hl.env("GUM_CONFIRM_SELECTED_BACKGROUND", "#343d41")
hl.env("GUM_CONFIRM_UNSELECTED_FOREGROUND", "#cacccc")
hl.env("GUM_CONFIRM_UNSELECTED_BACKGROUND", "#101315")
hl.env("GUM_CHOOSE_CURSOR_FOREGROUND", "#798186")
hl.env("GUM_CHOOSE_SELECTED_FOREGROUND", "#a5aeb4")
hl.env("GUM_FILTER_PROMPT_FOREGROUND", "#798186")
hl.env("GUM_FILTER_MATCH_FOREGROUND", "#798186")
hl.env("GUM_FILTER_INDICATOR_FOREGROUND", "#798186")
hl.env("GUM_SPIN_SPINNER_FOREGROUND", "#798186")

-- NVIDIA. Uncomment on an NVIDIA machine (this laptop is AMD).
-- hl.env("NVD_BACKEND", "direct")
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.config({
  xwayland = {
    force_zero_scaling = true,
  },

  ecosystem = {
    no_update_news = true,
  },
})
