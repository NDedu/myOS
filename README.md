# myOS

My Hyprland desktop on a plain Arch install: Hyprland in Lua, Waybar, yazi, mako, fuzzel, ghostty.
This config is a blend of my own old hyprland config and some Omarchy configs (solitude theme) I liked while using it from 3.0 to 4.0.
Minimal install (with some devtools for myself), only pacman. Every script these configs call is in this folder.


## Install

While installing Arch select Hyprland Desktop Environment and btrfs (recommended), and select to install packages from pre-install.txt (also do the root settings detailed at the end too).
```sh
cd myOS
./install.sh --packages   # packages (pacman only) + configs, or ./install.sh for configs only
```

To do it by hand, follow `install.txt`. It lists every copy command the script runs.

Then log in through uwsm: pick **Hyprland (uwsm-managed)** in the display manager, or run `uwsm start hyprland.desktop`.
**SUPER + K** searches every keybinding.

`install.sh` copies each folder to its place and first moves anything already there to `*.bak.<timestamp>`.
It asks for a name and email first (for git commits and the compose shortcuts) and nothing else, then runs unattended.
`GIT_NAME` and `GIT_EMAIL` in the environment skip the questions; an empty answer leaves them unset.
It also sets the dark GTK theme and icons, enables gnome-keyring, and enables the low-battery timer. It doesn't touch `/etc`.
Two extras stay commented out, with the commands in `install.txt` (sections 7 and 9):
- the passwordless keyring
- making the power key open the system menu

**Running this will overwrites the configs already in place.**
**You may also want to change the logos waybar/logo.txt and hypr/screensaver.txt**

<p>
  <img width="49%" alt="screenshot-2026-09-18_11-32-08" src="https://github.com/user-attachments/assets/2d826042-bf84-429a-a6b2-1a33b73c0960" />
  <img width="49%" alt="screenshot-2026-09-18_11-35-16" src="https://github.com/user-attachments/assets/4bc8a088-210e-46cf-9123-5fb0402bd859" />
</p>

## Keybindings (highlights)

| Keys | Action |
| --- | --- |
| SUPER + SPACE / SUPER + ALT + SPACE | Main menu / app launcher (fuzzle) |
| SUPER + RETURN / SUPER + E | Terminal (in current dir) / ghostty |
| SUPER + SHIFT + F | yazi (ALT: in the terminal's directory; CTRL: Nautilus instead) |
| SUPER + SHIFT + B | Browser |
| SUPER + W | Close window |
| CTRL + SHIFT + ALT + DELETE | Close every window and go to workspace 1 (no confirmation) |
| SUPER + T / F / O | Float / fullscreen / pop out |
| SUPER + 1…0, SHIFT to move | Workspaces |
| SUPER + L | Toggle dwindle/scrolling on this workspace |
| SUPER + ESCAPE | System menu (lock, suspend, restart, shutdown) |
| SUPER + CTRL + L | Lock |
| SUPER + CTRL + I | Stay awake / allow idle screensaver (10 min) and lock (15 min) |
| SUPER + CTRL + comma | Do not disturb |
| SUPER + CTRL + R | Set reminder (ALT: show, SHIFT: clear) |
| SUPER + CTRL + N | Nightlight |
| SUPER + CTRL + P | Power profile |
| SUPER + CTRL + A / B / W / T | Audio / Bluetooth / Wi-Fi / btop |
| SUPER + SHIFT + SPACE | Hide/show bar |
| SUPER + BACKSPACE | Toggle transparency (SHIFT: gaps) |
| SUPER + CTRL + SPACE | Reload the wallpaper after replacing the image (also in the system menu). The image file and how it fits the screen are set at the top of `hypr/scripts/wallpaper-reload.sh` |
| PRINT / ALT + PRINT | Screenshot (RETURN window, CTRL + RETURN screen) / screen recording |
| SUPER + C / V / X | Copy / paste / cut everywhere |
| SUPER + K | All keybindings |

## What's where

| Folder | Installs to | What it is |
| --- | --- | --- |
| `hypr/` | `~/.config/hypr` | Hyprland config (Lua), hypridle, hyprlock, hyprsunset, portal, desktop and lock screen wallpapers, and `scripts/` |
| `waybar/` | `~/.config/waybar` | The bar: `hyprland.lua` and the Vantablack colors (other themes in `waybar/themes/`). Its `scripts/launcher.sh` also backs every fuzzel menu in `hypr/`, so the two folders install together |
| `mako/` | `~/.config/mako` | Notifications, with a do-not-disturb mode |
| `swayosd/` | `~/.config/swayosd` | Volume/brightness on-screen display |
| `fuzzel/` | `~/.config/fuzzel` | App launcher and the picker for every menu (clipboard, emojis, keybindings) |
| `ghostty/` | `~/.config/ghostty` | Terminal config, solitude theme, screensaver profile |
| `bash/`, `starship.toml`, `tmux/`, `btop/`, `fontconfig/`, `XCompose` | `~/.bashrc`, `~/.config/bash`, … | How the terminal behaves: aliases, functions, prompt, history search, tmux, btop theme, monospace font, compose key |
| `nvim/` | `~/.config/nvim` | Neovim (LazyVim): options, keymaps, cheatsheets (`<leader>kk`), LSP, ashen colorscheme. The first start downloads the plugins |
| `zed/` | `~/.config/zed` | Zed settings (vim mode, Ashen theme, no AI, no telemetry, per-language LSP choices) and keymap (Ctrl + E toggles the left dock). The first start installs the Ashen, HTML, SQL and Zig extensions |
| `imv/` | `~/.config/imv` | Image viewer keys: Ctrl + X trash (Ctrl + Shift + X trash and next), Ctrl + R rotate the file, Ctrl + E annotate in satty. Ctrl + P print is commented out until cups is installed |
| `lazygit/` | `~/.config/lazygit` | lazygit look: ashen colors, nerd font icons, no bottom line |
| `git/` | `~/.config/git` | Aliases, pull rebase, auto upstream, better diffs, rerere, global ignore. Name and email are asked at install time, not kept here |
| `nautilus/` | `~/.config/gtk-3.0/bookmarks`, dconf | Nautilus sidebar bookmarks and preferences (show hidden files, folders not sorted first) |
| `dolphin/` | `~/.config/dolphinrc`, `kiorc`, `kdeglobals` | Dolphin settings (kept; Nautilus is the default), ghostty for "Open Terminal Here" (Shift+F4) |
| `yazi/` | `~/.config/yazi` | The yazi cheatsheet (`cheatsheet.md`): its keys and how to use it |
| `applications/` | `~/.local/share/applications` | `yazi.desktop`, so folders open yazi in ghostty (the package's own entry needs a terminal nothing here can find) |
| `mimeapps.list` | `~/.config/mimeapps.list` | Default apps: folders in yazi, videos in mpv, MP3 in VLC, images in imv, PDFs in Evince, web in Chromium |
| `uwsm/` | `~/.config/uwsm` | Session environment (`TERMINAL`, `EDITOR`) |
| `browser/` | `~/.config/chromium-flags.conf`, `brave-flags.conf` | Wayland flags, and passwords saved in gnome-keyring |
| `systemd/user/` | `~/.config/systemd/user` | Low battery warning timer |

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

## The setup

1. **Hyprland**: monitor scale 1.33, 3-finger workspace swipe, per-workspace scrolling layout, pop-out windows, universal copy/paste, laptop display off/mirroring, lid handling and zoom.
   **hypridle** stays awake by default. SUPER + CTRL + I (or the coffee cup 󰅶 in the bar's drawer) allows idle: screensaver after 10 minutes, lock after 15. **hyprsunset** is the night light (SUPER + CTRL + N), off at every login.
2. **Files**: **yazi** in ghostty (SUPER + SHIFT + F), also for folders opened from other apps. Its keys are in `yazi/cheatsheet.md`, and `~` inside yazi opens its help.
   **Nautilus** (SUPER + CTRL + SHIFT + F) has previews (Space), video thumbnails, phones and network shares, and shows hidden files. **Dolphin** stays available from "Open With".
3. **Lock screen**: hyprlock on `hypr/lockW.png`, time and date at the top, password field at the bottom. SUPER + CTRL + L locks. Locking before suspend and on lid close is commented out in `hypridle.conf` and `scripts/lid-close.sh`.
4. **Terminal**: ghostty in the solitude palette, JetBrainsMonoNL Nerd Font 9. Bash with eza, zoxide, fzf, history search on arrows and git aliases, plus Starship, tmux and btop. The screensaver prints `screensaver.txt` on a black screen until a key is pressed.
5. **Notifications**: mako, top right. SUPER + comma dismisses (SHIFT: all). SUPER + CTRL + comma or the bell (󰂛) toggles do not disturb, which still lets the desktop's own messages (reminders, screenshots, battery) through.
6. **Power**: SUPER + ESCAPE opens the system menu (the power key too, after `install.txt` section 9). SUPER + CTRL + P or a click on the battery picks the power profile. A warning at 10% battery.

### The rest of it

- **fuzzel**: the app launcher (SUPER + ALT + SPACE) and every menu: system, power profile, capture, toggles, keybindings, clipboard history (SUPER + CTRL + V) and emojis (SUPER + CTRL + E).
- **SwayOSD**: volume, brightness, keyboard backlight and mic mute. SHIFT + mute key switches the audio output.
- **Screenshots**: PRINT freezes the screen, then drag a region or click a window (RETURN: window, CTRL + RETURN: screen). Shots go to `~/Pictures` and the clipboard; click the notification to annotate in satty. SUPER + CTRL + PRINT is OCR, ALT + PRINT records, SUPER + PRINT picks a color, and SUPER + CTRL + C opens the capture menu (also QR codes).
- **gnome-keyring**: stores browser and app passwords (Chromium/Brave get `--password-store=gnome-libsecret`). The optional passwordless keyring (`install.txt` section 7) is only reasonable with full-disk encryption. Saved secrets live in `~/.local/share/keyrings/`, not here.
- **Waybar**: Vantablack colors (`waybar/scripts/theme-set.sh <name>` switches themes). The Hyprland logo opens the main menu. Hovering an arrow opens a drawer: calendar, reminders, night light, stay awake and do not disturb left of the clock; CPU, RAM, temperature and tray left of Bluetooth. Hover the clock for the calendar, or click the calendar icon for calcurse.
- **Weather**: right of the clock. Right-click changes the location (default `auto`), a click adds the wind.
- **Reminders**: SUPER + CTRL + R sets one (ALT: list, SHIFT: clear). They're systemd user timers, so they don't survive a reboot.
- **XCompose**: Right Alt is the compose key. `Right Alt space n` types the name and `space e` the email.
- **Also**: polkit agent for GUI password prompts, udiskie for USB automount.
- **Logo**: `waybar/logo.txt` and `hypr/screensaver.txt` hold the same ASCII wordmark, so a new one replaces both.

---

Parts of these configs started from [Omarchy](https://github.com/basecamp/omarchy) (MIT).
The migrations and documentations were done using AI.
