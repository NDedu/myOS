-- Services started with Hyprland (the bar is started from ~/.config/waybar/hyprland.lua).

local function launch_if_present(binary, command)
  if o.cmd_present(binary) then
    hl.exec_cmd(o.launch(command or binary))
  end
end

hl.on("hyprland.start", function()
  -- Slow app launch fix: hand the session environment to systemd and dbus first.
  hl.exec_cmd("systemctl --user import-environment")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- Wallpaper (the image and how it fits are set at the top of scripts/wallpaper-reload.sh)
  hl.exec_cmd(o.script("wallpaper-reload.sh", "--quiet"))

  -- Notifications, OSD, idle/lock
  hl.exec_cmd(o.launch("mako"))
  hl.exec_cmd(o.launch("swayosd-server"))
  hl.exec_cmd(o.launch("hypridle"))

  -- Password prompts for GUI apps
  if o.file_exists("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1") then
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  elseif o.file_exists("/usr/lib/hyprpolkitagent/hyprpolkitagent") then
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
  end

  -- Clipboard history for SUPER + CTRL + V
  launch_if_present("cliphist", "wl-paste --watch cliphist store")

  -- Recover the laptop display if it was left disabled without an external monitor
  hl.exec_cmd(o.launch(o.script("monitor-watch.sh")))

  -- Automount USB drives
  launch_if_present("udiskie", "udiskie --automount --no-notify --no-tray")

  -- Input method (fcitx5), only needed for languages typed through one (Chinese, Japanese, Korean...)
  -- launch_if_present("fcitx5", "fcitx5 --disable notificationitem")
end)

-- Extra autostart processes:
-- o.launch_on_start("my-service")
