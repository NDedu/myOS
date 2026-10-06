# niri

A second session next to Hyprland: pick **Niri** at the login screen. niri's own keys and tools, with the
Hyprland setup's look and apps. Nothing here changes the Hyprland session.

## Install

`./install.sh --packages` installs it along with the rest: the packages are in `packages.txt`, and the script copies
`niri/`, `swaylock/` and `swayidle/` to `~/.config`. By hand (after the rest of `install.txt`, since the bar,
notifications, launcher, wallpaper and a few scripts are shared):

```sh
sudo pacman -S --needed niri xwayland-satellite xdg-desktop-portal-gnome swaylock swayidle wlsunset wtype
cp -r niri ~/.config/niri
cp -r swaylock ~/.config/swaylock
cp -r swayidle ~/.config/swayidle
chmod +x ~/.config/niri/scripts/*.sh
```

niri reloads `config.kdl` on save. Check it with `niri validate`.

## niri next to Hyprland

| | niri | Hyprland |
| --- | --- | --- |
| Keys | Hyprland's, with niri's defaults for what Hyprland doesn't have (columns, overview, monitors). Super + K searches them all; Super + Shift + / shows niri's main ones | `hypr/modules/bindings/` |
| Workspaces | 1–5 always there and always the same (Super + 1–5); past them, niri's own: made as needed, gone when empty | 1–10 |
| New windows | the first window on an empty workspace takes the full width (`scripts/maximize-first.sh`); Super + Alt + F gives the normal width back | a lone window fills the screen |
| Look | the same: solitude border, 6 px corners, 10 px gaps, scale 1.33, no title bars, slightly see-through windows | `hypr/modules/` |
| Display scale | Super + / and Super + Alt + /, remembered for each monitor in `~/.local/state/niri/output-scales.kdl` (`scripts/display-scale.sh`) | the same keys and steps, in `~/.local/state/hypr/monitor-scales` |
| Focus | follows the mouse, unless that would scroll the view | follows the mouse |
| Lock screen | swaylock (`swaylock/config`): black, solitude ring | hyprlock with the logo |
| Idle | swayidle (`swayidle/config`). Stay awake by default; allowed: the screensaver at 10 minutes, lock at 15 | hypridle: the same |
| Screensaver | the logo on black (`scripts/launch-screensaver.sh`); the cursor hides after a minute without moving the mouse | the logo on black |
| Displays off | five minutes into any lock | the same |
| Suspend | locks first | the same |
| Screenshots | niri's own: PRINT a region (drag, then Space saves it), CTRL + PRINT the screen, ALT + PRINT the window. Saved to `~/Pictures` | `hypr/scripts/screenshot.sh` |
| Screen recording | Menu > Capture > Screenrecord, picked through the screen sharing portal | slurp picker |
| Bar | `waybar.jsonc`: the Hyprland bar with niri's workspaces | `waybar/config.jsonc` |
| Menu (the bar's logo) | `scripts/menu.sh` | `hypr/scripts/menu.sh` |
| Wallpaper | `hypr/scripts/wallpaper-reload.sh` (swaybg with `hypr/wallpaper.jpeg`), at login and on Super + Ctrl + Space | the same |
| Night light | wlsunset at 4000K (`scripts/nightlight.sh`): the bar's moon, Toggle > Nightlight | hyprsunset |
| Volume and brightness keys | niri's 10% steps with the SwayOSD pop-up | 5% steps, SwayOSD |
| Emojis | typed into the window with wtype, and on the clipboard | pasted |

## Shared, used as they are

`~/.config/waybar` (config, style, scripts), mako, fuzzel, SwayOSD, ghostty (with its screensaver profile),
`hypr/wallpaper.jpeg`, `hypr/screensaver.txt` and these scripts from `hypr/scripts/`: `clipboard.sh`, `ocr.sh`,
`qr.sh`, `reminder.sh`, `wallpaper-reload.sh`, `brightness-keyboard.sh`, `launch-browser.sh`, `launch-editor.sh`,
`launch-file-manager.sh`, `notify-time.sh`.
"Allow idle" (the coffee cup) and "Suspend in System Menu" are one setting for both sessions.

## Keys

- Hyprland keys left as niri's: Super + O (overview, also on Super + A), Super + J / L / Home (focus), Super + Ctrl + Left / Right (move the
  column), Alt + Print (window screenshot), the power key (suspend).
- niri keys moved for Hyprland's: full width to Super + Alt + F, floating to Super + T, tabs to Super + G, centering to
  Super + Alt + C and Super + Ctrl + Alt + C, filling the free space to Super + Ctrl + Alt + F, the other monitors to
  Super + Shift + H / J / K / L and Ctrl + Alt + Tab, the shortcut escape hatch to Super + Shift + Escape.
- Super + Ctrl + number moves the whole column to that workspace, Super + Shift + number only the window, and
  Super + Shift + Alt + number the window without following it.

## Not in niri

- No niri equivalent: zoom, the scratchpad, pseudo-tiling, saving a window's width, the gaps and square-window
  toggles, laptop display off and mirroring, touchpad keys.
