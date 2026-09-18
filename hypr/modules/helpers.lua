-- Shared helpers for the Hyprland Lua config, available everywhere as the global `o`.

o = {}

local home = os.getenv("HOME")

o.home = home
o.scripts = home .. "/.config/hypr/scripts/"
o.waybar_scripts = home .. "/.config/waybar/scripts/"
o.state = home .. "/.local/state/hypr/"

function o.shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function o.file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end

  return false
end

-- Hyprland reaps its own children, so os.execute() can't report an exit status
-- from inside the compositor. Read a marker off stdout instead.
function o.shell_succeeds(command)
  local pipe = io.popen("( " .. command .. " ) >/dev/null 2>&1 && echo OK")
  if not pipe then
    return false
  end

  local output = pipe:read("*a") or ""
  pipe:close()

  return output:find("OK", 1, true) ~= nil
end

function o.cmd_present(command)
  if command:find("/", 1, true) then
    return o.file_exists(command)
  end

  local path = os.getenv("PATH") or "/usr/local/bin:/usr/bin"
  for directory in (path .. ":"):gmatch("([^:]*):") do
    if o.file_exists((directory ~= "" and directory or ".") .. "/" .. command) then
      return true
    end
  end

  return false
end

-- Launch apps through uwsm when the session is managed by it (keeps each app in
-- its own systemd scope), plain exec otherwise.
local uwsm = o.cmd_present("uwsm-app")
  and (os.getenv("UWSM_FINALIZE_VARNAMES") ~= nil or o.shell_succeeds("systemctl --user is-active --quiet 'wayland-wm@*.service'"))

function o.launch(command)
  if uwsm then
    return "uwsm-app -- " .. command
  end

  return command
end

function o.script(name, args)
  return o.scripts .. name .. (args and (" " .. args) or "")
end

function o.waybar_script(name, args)
  return o.waybar_scripts .. name .. (args and (" " .. args) or "")
end

function o.exec_on_start(command)
  hl.on("hyprland.start", function()
    hl.exec_cmd(command)
  end)
end

function o.launch_on_start(command)
  o.exec_on_start(o.launch(command))
end

function o.notify(message)
  return "notify-send -u low " .. o.shell_quote(message)
end

-- Keybindings --------------------------------------------------------------

local keybindings = {}

-- Readable names for the code: keys used by the default bindings
local keycode_names = {
  ["code:10"] = "1", ["code:11"] = "2", ["code:12"] = "3", ["code:13"] = "4", ["code:14"] = "5",
  ["code:15"] = "6", ["code:16"] = "7", ["code:17"] = "8", ["code:18"] = "9", ["code:19"] = "0",
  ["code:20"] = "MINUS", ["code:21"] = "EQUAL", ["code:34"] = "[", ["code:35"] = "]",
  ["code:201"] = "COPILOT", ["mouse:272"] = "LEFT CLICK", ["mouse:273"] = "RIGHT CLICK",
  ["mouse_down"] = "SCROLL DOWN", ["mouse_up"] = "SCROLL UP",
}

-- o.bind(keys, description, dispatcher, options)
-- dispatcher is a shell command string, an hl.dsp.* dispatcher, or a Lua function.
function o.bind(keys, description, dispatcher, options)
  local opts = options or {}

  if description then
    opts.description = description
    local readable = keys:gsub("[%w_:]+", function(part)
      return keycode_names[part] or part
    end)
    table.insert(keybindings, readable .. "\t" .. description)
  end

  if type(dispatcher) == "string" then
    dispatcher = hl.dsp.exec_cmd(dispatcher)
  end

  hl.bind(keys, dispatcher, opts)
end

function o.write_keybindings_cache()
  local runtime = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
  local file = io.open(runtime .. "/hypr-keybindings.tsv", "w")
  if not file then
    return
  end

  file:write(table.concat(keybindings, "\n"), "\n")
  file:close()
end

-- Window rules -------------------------------------------------------------

-- o.window(match, rules): match is a class regex string, or a table of match fields.
function o.window(match, rules)
  rules.match = rules.match or {}

  if type(match) == "string" then
    rules.match.class = match
  else
    for key, value in pairs(match) do
      rules.match[key] = value
    end
  end

  hl.window_rule(rules)
end
