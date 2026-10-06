# myOS

My desktop on a plain Arch install: Hyprland and Niri, Waybar, yazi, mako, fuzzel, ghostty.
This config is a blend of my own old hyprland config and some Omarchy configs (solitude theme) I liked while using it from 3.0 to 4.0.
Minimal install (with some devtools for myself), only pacman. Every script these configs call is in this folder.


## Install

While installing Arch select Hyprland Desktop Environment and btrfs (recommended), and select to install packages from pre-install.txt (also do the root settings detailed at the end too).
```sh
git clone https://github.com/NDedu/myOS.git
cd myOS
./install.sh --packages   # packages (pacman only) + configs, or ./install.sh for configs only
```

**Running this will overwrite the configs already in place.**
**You may also want to change the logos waybar/logo.txt and hypr/screensaver.txt**, to use your own logo.

To do it by hand, follow `install.txt`. It lists every copy command the script runs.

Then log in through uwsm: pick **Hyprland (uwsm-managed)** in the display manager, or run `uwsm start hyprland.desktop`.
**Niri** is set up as a second session: pick it there instead (`niri/README.md`).
**SUPER + K** searches every keybinding.

`install.sh` copies each folder to its place and first moves anything already there to `*.bak.<timestamp>`.
It asks for a name and email first (for git commits and the compose shortcuts) and nothing else, then runs unattended.
`GIT_NAME` and `GIT_EMAIL` in the environment skip the questions; an empty answer leaves them unset.
It also sets the dark GTK theme and icons, enables gnome-keyring, and enables the low-battery timer. It doesn't touch `/etc`.
Two extras stay commented out, with the commands in `install.txt` (sections 7 and 9):
- the passwordless keyring
- making the power key open the system menu

<p>
  <img width="49%" alt="screenshot-2026-09-18_11-32-08" src="https://github.com/user-attachments/assets/2d826042-bf84-429a-a6b2-1a33b73c0960" />
  <img width="49%" alt="screenshot-2026-09-18_11-35-16" src="https://github.com/user-attachments/assets/4bc8a088-210e-46cf-9123-5fb0402bd859" />
</p>

## Keybindings (highlights)

### Common

| Keys | Action |
| --- | --- |
| SUPER + K | All keybindings |
| SUPER + SPACE / SUPER + ALT + SPACE | Main menu / app launcher (fuzzel) |
| SUPER + W | Close window |
| SUPER + RETURN / SUPER + E | Terminal (in current dir) / ghostty |
| SUPER + SHIFT + F | yazi (ALT: in the terminal's directory; CTRL: Nautilus instead) |
| SUPER + SHIFT + B | Browser |
| CTRL + SHIFT + ALT + DELETE | Close every window and go to workspace 1 (no confirmation) |
| SUPER + T / F | Float / fullscreen |
| SUPER + M / SUPER + CTRL + F | Full width / fullscreen inside the tile |
| SUPER + 1…0, SHIFT to move | Workspaces |
| SUPER + ESCAPE | System menu (lock, suspend, restart, shutdown) |
| SUPER + CTRL + L | Lock |
| SUPER + CTRL + I | Stay awake / allow idle screensaver (10 min) and lock (15 min) |
| SUPER + CTRL + comma | Do not disturb |
| SUPER + CTRL + R | Set reminder (ALT: show, SHIFT: clear) |
| SUPER + CTRL + N | Nightlight |
| SUPER + CTRL + P | Power profile |
| SUPER + CTRL + A / B / W / T | Audio / Bluetooth / Wi-Fi / btop |
| SUPER + SHIFT + SPACE | Hide/show bar |
| SUPER + BACKSPACE | Toggle transparency |
| SUPER + / and SUPER + ALT + / | Display scale up / down, remembered for each monitor |
| SUPER + CTRL + SPACE | Reload the wallpaper after replacing the image (also in the system menu). The image file and how it fits the screen are set at the top of `hypr/scripts/wallpaper-reload.sh` |
| SUPER + C / V / X | Copy / paste / cut everywhere |

### Hyprland

| Keys | Action |
| --- | --- |
| SUPER + O | Pop out (float and pin) |
| SUPER + L | Toggle dwindle/scrolling on this workspace |
| SUPER + S | Scratchpad (ALT: send the window there) |
| SUPER + SHIFT + arrows | Swap the window with its neighbor |
| SUPER + SHIFT + BACKSPACE | Toggle gaps |
| PRINT / ALT + PRINT | Screenshot (RETURN window, CTRL + RETURN screen) / screen recording |

### Niri

| Keys | Action |
| --- | --- |
| SUPER + A or SUPER + O | Overview of all workspaces and windows (also the top-left corner, or four fingers up on the touchpad) |
| SUPER + SHIFT + arrows (or CTRL) | Move the column left / right, the window up / down in its column |
| SUPER + CTRL + 1…9 | Move the whole column to that workspace (SHIFT moves only the window) |
| SUPER + R | Column width: 1/3, 1/2, 2/3 (SHIFT: back) |
| SUPER + M | A workspace's first window opens full width; SUPER + M gives it the normal width |
| SUPER + ALT + M | Maximize to the screen edges, without gaps or border |
| SUPER + G | Tabs on/off in this column |
| PRINT / CTRL + PRINT / ALT + PRINT | Screenshot a region (SPACE saves it) / the screen / the window (Menu > Capture records the screen) |

## The setup

1. a) **Hyprland**: monitor scale 1.33, 3-finger workspace swipe, per-workspace scrolling layout, pop-out windows, universal copy/paste, laptop display off/mirroring, lid handling and zoom.
   **hypridle** stays awake by default. SUPER + CTRL + I (or the coffee cup in the bar's drawer) allows idle: screensaver after 10 minutes, lock after 15. **hyprsunset** is the night light (SUPER + CTRL + N), off at every login.\
   b) **Niri**: the second session, with Hyprland's look and keys (`niri/README.md` compares the two). Monitor scale 1.33, scrolling columns, workspaces 1–5 always there, a workspace's first window at full width, the overview (SUPER + A, the top-left corner or a 4-finger swipe up), 3-finger swipes across columns and workspaces, universal copy/paste.
   **swayidle** does hypridle's job, with the same switch and times. **hyprlock** is the lock screen too, the same as in Hyprland (swaylock if it doesn't start). **wlsunset** is the night light (SUPER + CTRL + N), off at every login.
2. **Files**: **yazi** in ghostty (SUPER + SHIFT + F), also for folders opened from other apps. Its keys are in `yazi/cheatsheet.md`, and `~` inside yazi opens its help.
   **Nautilus** (SUPER + CTRL + SHIFT + F) has previews (Space), video thumbnails, phones and network shares, and shows hidden files. **Dolphin** stays available from "Open With".
3. **Lock screen**: hyprlock on black with the logo in the middle (the same `screensaver.txt` as the screensaver), time and date at the top, password field at the bottom. SUPER + CTRL + L locks, and the displays turn off five minutes later (any key wakes them). It also locks before every suspend, from the menu or by closing the lid.
4. **Terminal**: ghostty in the solitude palette, JetBrainsMonoNL Nerd Font 9. Bash with eza, zoxide, fzf, history search on arrows and git aliases, plus Starship, tmux and btop. The screensaver prints `screensaver.txt` on a black screen until a key is pressed.
5. **Notifications**: mako, top right. SUPER + comma dismisses (SHIFT: all). SUPER + CTRL + comma or the bell toggles do not disturb, which still lets the desktop's own messages (reminders, screenshots, battery) through.
6. **Power**: SUPER + ESCAPE opens the system menu (the power key too, after `install.txt` section 9). SUPER + CTRL + P or a click on the battery picks the power profile. A warning at 10% battery.
7. **Waybar**: Solitude colors (`waybar/scripts/theme-set.sh <name>` switches themes). The star logo opens the main menu. Hovering an arrow opens a drawer: calendar, reminders, night light, stay awake and do not disturb left of the clock; CPU, RAM, temperature and tray left of Bluetooth. Hover the clock for the calendar, or click the calendar icon for calcurse.
8. **fuzzel**: the app launcher (SUPER + ALT + SPACE) and every menu: system, power profile, capture, toggles, keybindings, clipboard history (SUPER + CTRL + V) and emojis (SUPER + CTRL + E).

### The rest of it

- **SwayOSD**: volume, brightness, keyboard backlight and mic mute. SHIFT + mute key switches the audio output.
- **Screenshots**: PRINT freezes the screen, then drag a region or click a window (RETURN: window, CTRL + RETURN: screen). Shots go to `~/Pictures` and the clipboard; click the notification to annotate in satty. SUPER + CTRL + PRINT is OCR, ALT + PRINT records, SUPER + PRINT picks a color, and SUPER + CTRL + C opens the capture menu (also QR codes).
  In niri, PRINT is niri's own tool (drag a region, then SPACE saves it; CTRL + PRINT the screen, ALT + PRINT the window), also to `~/Pictures` and the clipboard, and Menu > Capture > Screenrecord records. OCR, the color picker and the capture menu are the same.
- **gnome-keyring**: stores browser and app passwords (Chromium/Brave get `--password-store=gnome-libsecret`). The optional passwordless keyring (`install.txt` section 7) is only reasonable with full-disk encryption. Saved secrets live in `~/.local/share/keyrings/`.
- **Weather**: right of the clock. Right-click changes the location (default `auto`), a click adds the wind.
- **Reminders**: SUPER + CTRL + R sets one (ALT: list, SHIFT: clear). They're systemd user timers, so they don't survive a reboot.
- **XCompose**: Right Alt is the compose key. `Right Alt space n` types the name and `space e` the email.
- **Also**: polkit agent for GUI password prompts, udiskie for USB automount.
- **Niri only**: xwayland-satellite runs X11 apps, xdg-desktop-portal-gnome does screen sharing and recording, wtype types the emojis and the universal copy/paste keys.
- **Logo**: `waybar/logo.txt` and `hypr/screensaver.txt` hold the same ASCII wordmark, so a new one replaces both. The screensaver and the lock screen both draw `screensaver.txt`.

### Hyprland config layout

`hypr/hyprland.lua` loads `modules/` in order:

- `helpers.lua`: `o.bind`, `o.window`, `o.launch`
- `envs.lua`, `monitors.lua`, `input.lua`
- `looknfeel.lua`: gaps, animations, layouts
- `theme.lua`: solitude border gradient and rounding
- `windows.lua`: window and layer rules
- `autostart.lua`
- `bindings/`: applications, tiling, media, clipboard, utilities
- `toggles.lua`: runtime state from `~/.local/state/hypr` (gaps off, laptop display off, per-workspace layout)

### Niri config layout

`niri/config.kdl` is one file, in this order:

- `input` (keyboard, touchpad, focus follows the mouse)
- the scales picked with SUPER + / (included from `~/.local/state/niri/output-scales.kdl`), then `output "eDP-1"` (scale 1.33)
- `workspace "1"` to `"5"`
- `layout`: gaps, column widths, the solitude border
- `cursor`, `prefer-no-csd`, `screenshot-path`, `environment` (Hyprland's variables)
- startup apps, as in `autostart.lua`, with swaybg, swayidle and `scripts/maximize-first.sh`
- window rules: rounding, transparency, the screensaver, floating terminals, hidden from screen sharing
- `binds`: niri's keys, Hyprland's where the two clash, then the rest of the Hyprland keys

Next to it: `waybar.jsonc` (the Hyprland bar with niri's workspaces) and `scripts/` (the niri versions of Hyprland's scripts). The idle times are `swayidle/config`; the lock screen is Hyprland's `hyprlock.conf`, with `swaylock/config` as the fallback.

---

Parts of these configs started from [Omarchy](https://github.com/basecamp/omarchy) (MIT).
The migrations and documentations were done using AI.
