# yazi cheatsheet

The file manager. A terminal app, driven like vim: move with `hjkl`, act with single keys.
Keys below are yazi 26.9's defaults. Press `~` (or F1) inside yazi for the full list.

## Opening it

| Keys | What |
| --- | --- |
| SUPER + SHIFT + F | yazi in your home directory |
| SUPER + ALT + SHIFT + F | yazi in the directory of the terminal you're in |
| SUPER + CTRL + SHIFT + F | Nautilus (the window-based one) instead |

Folders opened from other apps (a browser's "show in folder", a file dialog) open yazi too.

## Moving around

| Keys | What |
| --- | --- |
| `j` `k` (or arrows) | Down, up |
| `l` / `h` | Enter the directory / back to the parent |
| `L` / `H` | Forward / back in history, like a browser |
| `gg` / `G` | First / last file |
| `Ctrl+d` / `Ctrl+u` | Half a page down / up |
| `g h` · `g c` · `g d` | Go to home · `~/.config` · `~/Downloads` |
| `g <Space>` | Type a path to jump to |
| `z` / `Z` | Jump with fzf (name search) / zoxide (directories you've visited) |
| `t t` · `1`…`9` · `[` `]` | New tab · go to tab N · previous/next tab |
| `q` · `Ctrl+c` | Quit · close this tab |

## Files

| Keys | What |
| --- | --- |
| `Enter` or `o` | Open with your default app (images in imv, video in mpv, text in nvim) |
| `O` | Open with… pick the app |
| `Space` | Select the file, and move down |
| `v` · `Ctrl+a` · `Esc` | Select a range · select all · clear the selection |
| `y` · `x` · `p` | Copy · cut · paste (`P` overwrites what's there) |
| `d` · `D` | Move to trash · delete for good |
| `a` · `r` | Create (end the name with `/` for a directory) · rename |
| `c c` / `c f` | Copy the file's full path / just its name to the clipboard |
| `y` (then paste elsewhere) | Yanked files also go to the system clipboard, so file dialogs (upload, attach) take them |
| `Tab` | Show details of the file (size, dates, permissions) |
| `J` / `K` | Scroll the preview on the right |
| `w` | Running tasks (copies, deletes) |

## Finding things

| Keys | What |
| --- | --- |
| `f` | Filter: type to hide everything that doesn't match |
| `/` · `n` / `N` | Find in this directory · next / previous match |
| `s` / `S` | Search by file name (fd) / by text inside files (ripgrep) |
| `.` | Show or hide hidden files |
| `, s` · `, m` · `, a` | Sort by size · by modified time · alphabetically (capital letter reverses) |

## Running commands

| Keys | What |
| --- | --- |
| `;` | Run a shell command (`$0` is the hovered file, `$@` the selected ones) |
| `:` | Same, but wait and show the output before returning |

Example: select some files with `Space`, press `;`, and run `zip -r out.zip "$@"`.

## Getting files into other apps

yazi draws in a terminal, so there's nothing to drag out of. Instead, press `y` and paste in the other app:
that works in file dialogs (uploading, attaching) and in text fields, which get the path.
Pasting into Nautilus as a file needs GNOME's own clipboard type, which this can't provide, so copy inside
yazi with `y` and `p` instead. The `y` behaviour comes from `~/.config/yazi/keymap.toml`.
