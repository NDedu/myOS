# Packages

Every package comes from the official Arch repos, so pacman is enough: nothing comes from the AUR.
The list is `packages.txt`. Install it with `./install.sh --packages`, or by hand:

```sh
grep -v -e '^#' -e '^\s*$' packages.txt | sudo pacman -S --needed -
```

| Feature | Packages |
| --- | --- |
| Hyprland session | `hyprland` `uwsm` `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` `hyprland-guiutils` `qt5-wayland` `qt6-wayland` `polkit-gnome` `xdg-utils` `xorg-xwayland` |
| Hyprland's own libraries (come with `hyprland`; listed so they stay explicitly installed) | `aquamarine` `hyprlang` `hyprutils` `hyprgraphics` `hyprcursor` `hyprwayland-scanner` `gsettings-desktop-schemas` |
| Idle, lock, nightlight, wallpaper | `hypridle` `hyprlock` `hyprsunset` `swaybg` |
| Notifications + do not disturb | `mako` `libnotify` |
| Volume/brightness OSD | `swayosd` |
| App launcher and menus, clipboard history, emoji picker | `fuzzel` `cliphist` `unicode-emoji` |
| Bar | `waybar` `pamixer` `pacman-contrib` `wiremix` `bluetui` `bluez` `bluez-utils` |
| Network (Wi-Fi, Ethernet, VPN) | `networkmanager` (includes `nmtui`) |
| Terminal and fonts | `ghostty` (what the configs launch) `alacritty` `ttf-jetbrains-mono-nerd` `noto-fonts` `noto-fonts-emoji` `ttf-liberation` `ttf-jetbrains-mono` `ttf-nerd-fonts-symbols` `ttf-noto-nerd` `woff2-font-awesome` |
| Shell | `bash-completion` `git` `lazygit` `openssh` `starship` `eza` `fzf` `zoxide` `bat` `neovim` `ripgrep` `fd` `tree-sitter-cli` `gcc` `unzip` `zip` `luarocks` `tmux` `gum` `btop` `man-db` `man-pages` `wget` `make` `github-cli` `fastfetch` |
| Editors | `vim` `nano` `kate` (`neovim` above, `zed` below) |
| Languages and language servers | `go` `gopls` `zig` `zls` `clang` `rust` |
| File manager (yazi, the default): previews for archives, PDFs and images | `yazi` `7zip` `poppler` `imagemagick` (`fd` `ripgrep` `fzf` `zoxide` above power its search and jump keys) |
| Nautilus (windowed, on its own key): preview with Space, video thumbnails, phones, network shares | `nautilus` `sushi` `ffmpegthumbnailer` `gvfs-mtp` `gvfs-smb` `gvfs-nfs` |
| Dolphin (kept, not the default) and icons | `dolphin` `kio-extras` `ffmpegthumbs` `kdegraphics-thumbnailers` `archlinux-xdg-menu` `gnome-themes-extra` `papirus-icon-theme` `breeze-icons` |
| Audio, brightness, media keys | `pipewire` `pipewire-pulse` `wireplumber` `brightnessctl` `playerctl` |
| Power profiles, battery | `power-profiles-daemon` `upower` |
| Btrfs snapshots (optional, btrfs only) | `snapper` — add `snap-pac` for pacman hooks; setup in install.txt section 11 |
| Screenshots, annotation, OCR, QR codes, color picker, recording | `grim` `slurp` `satty` `hyprpicker` `wl-clipboard` `tesseract` `tesseract-data-eng` `zbar` `gpu-screen-recorder` `ffmpeg` `v4l-utils` |
| Password storage (gnome-keyring) | `gnome-keyring` `libsecret` |
| Script helpers | `jq` `socat` `curl` |
| Apps opened by bindings and default file types | `obsidian` `zed` `lazydocker` `vlc` `udiskie` `gnome-calculator` `calcurse` `imv` `mpv` `evince` `chromium` |
| Other apps | `firefox` `flatpak` `gparted` `pinta` `xarchiver` |

## Swapped-out packages

A few of the tools these configs used aren't in the official repos. What's used instead:

| Instead of | Now | Notes |
| --- | --- | --- |
| walker + elephant (launcher, clipboard, emojis) | `fuzzel`, `cliphist`, `unicode-emoji` | Same keys: SUPER + ALT + SPACE, SUPER + CTRL + V, SUPER + CTRL + E |
| xdg-terminal-exec | ghostty called directly | `TERMINAL=ghostty` |
| yaru-icon-theme (Yaru-sage-dark) | `papirus-icon-theme` (Papirus-Dark) | `breeze-dark` or `Adwaita` swap in cleanly: change the `gsettings` command in install.txt and `~/.config/kdeglobals` |
| tensaku (screenshot editor) | `satty` | |
| ttfx / terminaltexteffects (screensaver) | `hypr/scripts/screensaver.sh` | Plain bash: the logo, centered and static |
| hyprland-preview-share-picker | the portal's default picker | Comes with `xdg-desktop-portal-hyprland` |

## Notes

- **Network:** `sudo systemctl enable --now NetworkManager`. The bar's network icon and SUPER + CTRL + W open `nmtui`. impala isn't included: it only works with iwd running and NetworkManager disabled.
- **Bluetooth:** `sudo systemctl enable --now bluetooth`.
- **Power profiles:** `sudo systemctl enable --now power-profiles-daemon`. It's needed for power profile switching.
- **Neovim:** `ripgrep` and `fd` power file and text search. `tree-sitter-cli` and `gcc` build syntax parsers, `unzip` is used by Mason to install language servers, and `luarocks` is used by plugins that need Lua packages. The Go extra's `gopls` needs Go, which is the `go` package above.
- **Docker:** `lazydocker` (SUPER + SHIFT + D) only manages Docker. Docker itself is `docker`, plus `sudo systemctl enable --now docker`.
- **Optional:** `seahorse` is a GUI for browsing the keyring. `konsole` makes Dolphin's F4 terminal panel work (the panel can only embed Konsole; Shift+F4 opens ghostty either way).
- **More OCR languages:** install `tesseract-data-<lang>` and set `OCR_LANGS=eng+ron`.
