-- Application bindings.

local function tui(command)
  return o.waybar_script("launch-or-focus-tui.sh", command)
end

local function launch_or_focus(match, command)
  return o.script("launch-or-focus.sh", o.shell_quote(match) .. " " .. o.shell_quote(o.launch(command)))
end

o.bind("SUPER + RETURN", "Terminal", o.script("launch-terminal.sh"))
o.bind("SUPER + E", "Terminal (ghostty)", o.launch("ghostty"))
o.bind("SUPER + SHIFT + RETURN", "Browser", o.script("launch-browser.sh"))
o.bind("SUPER + SHIFT + B", "Browser", o.script("launch-browser.sh"))
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", o.script("launch-browser.sh", "--private"))
o.bind("SUPER + SHIFT + F", "File manager (yazi)", o.script("launch-file-manager.sh"))
o.bind("SUPER + ALT + SHIFT + F", "File manager (yazi, cwd)", o.script("launch-file-manager.sh", "--cwd"))
o.bind("SUPER + CTRL + SHIFT + F", "File manager (Nautilus)", o.script("launch-file-manager.sh", "--nautilus"))
o.bind("SUPER + SHIFT + N", "Editor", o.script("launch-editor.sh"))
o.bind("SUPER + ALT + RETURN", "Tmux", o.script("launch-terminal.sh", "-e bash -c 'tmux attach || tmux new -s Work'"))

-- Apps
o.bind("SUPER + SHIFT + D", "Docker", tui("lazydocker"))
o.bind("SUPER + SHIFT + O", "Obsidian", launch_or_focus("^obsidian$", "obsidian"))
