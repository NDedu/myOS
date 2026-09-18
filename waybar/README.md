# Waybar

A self-contained Waybar config: no external commands or environment variables, every script the
bar calls is in `scripts/`.

It works the other way round too: the Hyprland config in `../hypr` calls `scripts/launcher.sh`
for every fuzzel menu (system, capture, toggle, hardware, reminders) and `scripts/power-profile-menu.sh`
for SUPER + CTRL + P. Installing `hypr/` without this folder leaves those menus broken, so the two install together.
Every script the bar calls lives in `scripts/`.

## Install

Copy this folder anywhere and run:

```sh
./install.sh
```

It copies the folder to `~/.config/waybar` (an existing one is moved to `waybar.bak.<timestamp>`),
and lists missing packages. Then load the Hyprland integration.
With a Lua config (`hyprland.lua`, Hyprland 0.55+; the myOS hypr config already does this):

```lua
dofile(os.getenv("HOME") .. "/.config/waybar/hyprland.lua")
```

With the old hyprlang config (`hyprland.conf`):

```
source = ~/.config/waybar/hyprland.conf
```

Either file starts the bar, floats the terminals it opens, and adds the toggle keys.

## What the clicks do

| Module | Left click | Right click |
| --- | --- | --- |
| Hyprland logo | Main menu (apps, capture, reminders, toggles, system...) | Terminal |
| Clock (hover shows this month's calendar) | Switch between time and date view (`format` / `format-alt`) | Timezone picker |
| Weather: temperature and condition icon (moon at night; hover shows place, temperature and conditions) | Notification with the wind too | Change the location: a city, or `auto` for the IP-based location (saved in `weather-location`) |
| Update icon (shown when updates exist) | `sudo pacman -Syu` in a floating terminal | |
| Recording indicator (only while recording) | Stop recording | |
| Arrows (left of the clock, left of Bluetooth) | Hover to open that drawer: the arrow slides left and turns into `>` while open | |
| Left of the clock: calendar icon | calcurse in a floating terminal (focuses it if already open) | |
| Left of the clock: reminder clock | Show reminders, or set one when there are none: bright while reminders are pending | Set a new reminder |
| Left of the clock: night light | Toggle night light (warm screen): bright while on | |
| Left of the clock: coffee cup | Toggle stay awake / allow idle screensaver (10 min) and lock (15 min): bright while staying awake | |
| Left of the clock: bell | Toggle do not disturb: bright while silenced, dimmed while notifications show (default) | |
| Left of Bluetooth: CPU (usage %) | btop | Terminal |
| Left of Bluetooth: RAM (usage %, hover for GB used) | btop | |
| Left of Bluetooth: CPU temperature (fire icon at 80°C and above) | btop | |
| Left of Bluetooth: apps' tray icons | Depends on the app | |
| Bluetooth | bluetui (or blueman) | |
| Volume | wiremix (or pavucontrol) | Mute |
| Brightness (sun fills up with the level, scroll to change it) | | |
| Network (hover shows download/upload speed) | nmtui (or impala) | |
| Battery | Power profile picker | Battery status notification |

To change the clock's look, edit `format` and `format-alt` in the `clock` block of `config.jsonc`.

## Scripts

| Script | Purpose |
| --- | --- |
| `restart-waybar.sh` | Restart the bar |
| `reset-waybar.sh` | Restore `config.jsonc` and `style.css` from `defaults/` (keeps a `.bak` of the current ones), then restart |
| `toggle-waybar.sh` | Hide/show the bar |
| `theme-set.sh [name]` | Set bar colors from `themes/` (run it with no name to list themes) |
| `screenrecording.sh` | Start/stop recording (`--with-desktop-audio`, `--with-microphone-audio`, `--with-webcam`) |
| `tz-select.sh` | Pick the system timezone |
| `launcher.sh` | App launcher, or a picker with `--dmenu "Prompt"`. Point it at another menu to reuse it |

Customize `config.jsonc` and `style.css`, and leave `defaults/` untouched so the reset script has a clean copy.

## Notes

- The logo is the Hyprland logo from JetBrainsMonoNL Nerd Font (U+F359) and opens the main menu from ~/.config/hypr/scripts/menu.sh.
  To use an image instead, save it as `logo.svg` in this folder (white, so it shows on the dark bar) and replace
  `custom/logo` with `image#logo` in `modules-left` of `config.jsonc`.
- The update icon tracks pacman package updates (`checkupdates`).
- Colors come from `colors.css` (Vantablack by default, see `themes/vantablack.css`). Switch with `scripts/theme-set.sh <name>`.
- Terminals get the app-id `org.waybar.*`, which the window rules in `hyprland.conf` match.
- Notification silencing supports mako, swaync and dunst. With mako, the config needs a
  `[mode=do-not-disturb]` section with `invisible=true`.
