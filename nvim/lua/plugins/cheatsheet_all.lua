-- ~/.config/nvim/lua/plugins/cheatsheet.lua
-- Floating cheatsheet window: <leader>kk
--
-- Note: the cheatsheet text uses [==[ ... ]==] (level-bracketed long string)
-- because the content itself contains ]] characters (e.g. the [[ / ]] motion).

local cheatsheet = [==[
# Neovim / LazyVim Cheatsheet

Press `q` or `<Esc>` to close. `/pattern` to search inside this window.

## Motions
  w / W           Next word / WORD start
  e / E           Next word / WORD end
  b / B           Previous word start
  ge / gE         Previous word end
  0 / ^ / $       Line: col 0 / first non-blank / end
  gg / G          File: start / end
  {n}G            Go to line n  (e.g. 42G)
  M               Screen: middle  (H/L are remapped → prev/next buffer)
  zz / zt / zb    Center / top / bottom this line
  %               Jump to matching bracket
  f{c} / F{c}     Find char forward / back (in line)
  t{c} / T{c}     Till char forward / back (in line)
  ; / ,           Repeat last f/t / reverse
  ( / )           Sentence: start / end
  { / }           Paragraph: up / down
  [[ / ]]         LSP buffer: prev / next reference; else section motion
  <C-d> / <C-u>   Half-page down / up
  <C-f> / <C-b>   Full page down / up
  <C-e> / <C-y>   Scroll down / up one line (cursor stays)
  <C-o> / <C-i>   Jumplist: back / forward
  '' / ``         Last jump: line / exact column
  gd              LSP go to definition (also a motion)

## Editing
  i / a           Insert before / after cursor
  I / A           Insert at line start / end
  o / O           Open line below / above
  r{c} / R        Replace one char / replace mode
  ciw  caw        Change inner word / a word (incl. space)
  ci" ci( ci{ cit Change inside quotes / parens / braces / tag
  diw daw         Delete inner / a word
  yiw yaw         Yank inner / a word
  >> / <<         Indent / dedent line
  ==              Auto-indent line
  J               Join with line below (gJ to keep spaces)
  ~               Toggle case of char
  gu{m} / gU{m}   Lowercase / uppercase over motion
  u / <C-r>       Undo / redo
  .               Repeat last change
  <C-a> / <C-x>   Increment / decrement number under cursor
  g<C-a>          Sequential increment (in visual-block — make 1,1,1 → 1,2,3)

## Insert mode (useful while typing)
  <C-w>               Delete previous word
  <C-u>               Delete to start of line
  <C-h>               Backspace
  <C-r>{reg}          Paste from register (e.g. <C-r>" for last yank, <C-r>+ for clipboard)
  <C-r>=              Insert from expression (e.g. <C-r>=2+2 inserts 4)
  <C-o>{cmd}          Run one normal command then back to insert
  <C-x><C-l>          Line completion
  <C-x><C-f>          File path completion
  <C-x><C-o>          Omni / LSP completion

## Text objects (combine with d / c / y / v)
  iw / aw             Inner / around word
  iW / aW             Inner / around WORD (whitespace-separated)
  is / as             Inner / around sentence
  ip / ap             Inner / around paragraph
  i" / a"             Inside / around double quotes  (also i' i`)
  i( / a(             Inside / around parens         (also i) ib)
  i[ / a[             Inside / around brackets       (also i])
  i{ / a{             Inside / around braces         (also iB)
  it / at             Inside / around HTML/XML tag

## Comments (mini.comment — LazyVim default)
  gcc                 Toggle comment on line
  gc{motion}          Comment over motion (e.g. gcap = paragraph)
  {visual}gc          Comment selection
  gco / gcO           Add comment line below / above + insert mode

## Surround (mini.surround — LazyVim default)
  gsa{motion}{c}      Add surround (e.g. gsaiw" wraps word in quotes)
  gsd{c}              Delete surround (e.g. gsd" removes quotes)
  gsr{old}{new}       Replace surround (e.g. gsr({ changes ( to {)
  gsf / gsF           Find surround right / left
  gsh                 Highlight surround

## Buffers (LazyVim)
  <S-h> / <S-l>       Previous / next buffer
  <leader>bb          Switch to other buffer (last used)
  <leader>bd          Delete buffer (keep window)
  <leader>bD          Delete buffer + window
  <leader>bo          Delete other buffers
  <leader>bp          Toggle pin buffer
  <leader>bP          Delete non-pinned buffers

## Tabs (LazyVim)
  <leader><tab><tab>  New tab
  <leader><tab>d      Close tab
  <leader><tab>]      Next tab
  <leader><tab>[      Previous tab
  <leader><tab>f      First tab
  <leader><tab>l      Last tab
  <leader><tab>o      Close other tabs

## Windows
  <C-w>s / <C-w>v     Split horizontal / vertical
  <C-w>q              Close window
  <C-w>o              Close all other windows
  <C-h/j/k/l>         Move to window left/down/up/right
  <C-w>=              Equalize sizes
  <C-w>_  <C-w>|      Maximize height / width
  <C-Up/Down>         Resize height
  <C-Left/Right>      Resize width
  <C-w>T              Move current window to new tab

## Find / Pickers (LazyVim — Snacks picker)
  <leader><space>     Find files (root)
  <leader>ff          Find files (cwd)
  <leader>fr          Recent files
  <leader>fb          Buffers
  <leader>fc          Config files
  <leader>/           Grep in project
  <leader>sg          Live grep
  <leader>sw          Grep word under cursor (works in visual too)
  <leader>sb          Lines in current buffer
  <leader>sh          Help tags
  <leader>sk          Keymaps
  <leader>sc          Command history
  <leader>sd          Diagnostics
  <leader>sR          Resume last picker
  <leader>n           Notification history (Snacks)
  <leader>s"          Registers
  <leader>sm          Marks
  <leader>sj          Jumplist
  <leader>,           Buffers (alt)
  <leader>:           Command history (alt)

## LSP
  gd                  Go to definition
  gD                  Go to declaration
  gr                  References
  gI                  Implementations
  gy                  Type definition
  K                   Hover docs (press twice to enter the float)
  gK                  Signature help (normal)
  <C-k>  (insert)     Signature help
  <leader>ca          Code action
  <leader>cr          Rename symbol
  <leader>cf          Format
  <leader>cd          Line diagnostics
  ]d / [d             Next / prev diagnostic
  ]e / [e             Next / prev error
  ]w / [w             Next / prev warning
  <leader>uh          Toggle inlay hints

## Trouble / Diagnostics
  <leader>xx          Workspace diagnostics
  <leader>xX          Buffer diagnostics
  <leader>xL          Location list
  <leader>xQ          Quickfix list
  <leader>cs          Symbols (Trouble)
  <leader>cS          LSP refs / defs / impls

## Explorer (Snacks Explorer — LazyVim default)
  <leader>e           Explorer (root dir)
  <leader>E           Explorer (cwd)
  <leader>fe          Explorer (root dir)
  <leader>fE          Explorer (cwd)

## Visual mode
  v / V / <C-v>       Charwise / linewise / blockwise
  o                   Swap selection ends (extend other side)
  gv                  Reselect last visual
  >  / <              Indent / dedent
  =                   Auto-indent
  J                   Join lines
  u / U               Lowercase / uppercase
  ~                   Toggle case
  <C-v> I {text} Esc  Block insert at start of each line
  <C-v> A {text} Esc  Block insert at end of each line

## Search & Replace
  /pat / ?pat         Search forward / back
  n / N               Next / prev match
  * / #               Search word under cursor (fwd / back)
  :nohl   <Esc>       Clear highlight
  :%s/old/new/g       Replace in file
  :%s/old/new/gc      Replace with confirm
  :s/old/new/g        Replace in current line
  :'<,'>s/old/new/g   Replace in visual selection
  <leader>sr          grug-far (project find/replace UI)

## Spelling (when :set spell)
  ]s / [s             Next / prev misspelled word
  z=                  Suggestions for word under cursor
  zg                  Add word to dictionary (good)
  zw                  Mark word as wrong
  zG / zW             Same, but session-only (not saved)

## Marks & Registers
  m{a-z}              Set local mark
  m{A-Z}              Set global mark (across files)
  '{m} / `{m}         Jump to mark: line / exact column
  :marks              List marks
  "{r}y  "{r}p        Yank / paste using register r
  "+y / "+p           System clipboard yank / paste
  "0p                 Paste last yank (not last delete)
  "_d                 Delete to black hole (no yank)
  :reg                List registers

## Macros
  q{a}                Start recording into register a
  q                   Stop recording
  @{a}                Replay macro a
  @@                  Replay last macro
  {n}@{a}             Replay n times (e.g. 50@a)

## Folds
  za                  Toggle fold
  zo / zc             Open / close fold
  zO / zC             Open / close recursively
  zR / zM             Open all / close all folds
  zj / zk             Next / prev fold

## Quickfix / Location list
  ]q / [q             Next / prev quickfix
  ]l / [l             Next / prev loclist
  <leader>xq          Toggle quickfix
  <leader>xl          Toggle loclist

## Git (LazyVim + gitsigns)
  <leader>gg          LazyGit (root)
  <leader>gG          LazyGit (cwd)
  <leader>gb          Git blame line
  <leader>gB          Git browse (open in remote)
  ]h / [h             Next / prev hunk
  <leader>ghs         Stage hunk
  <leader>ghr         Reset hunk
  <leader>ghp         Preview hunk inline
  <leader>ghb         Blame line (full)
  <leader>ghd         Diff this file
  <leader>ghD         Diff this file vs ~

## Terminal
  <leader>ft          Floating terminal (root dir)
  <leader>fT          Floating terminal (cwd)
  <C-/>               Toggle terminal (root dir)
  <Esc><Esc>          Exit terminal mode → normal mode

## Toggles (LazyVim)
  <leader>uw          Word wrap
  <leader>us          Spell
  <leader>ul          Line numbers
  <leader>uL          Relative numbers
  <leader>uc          Conceal
  <leader>uh          Inlay hints
  <leader>uf          Autoformat (global)
  <leader>uF          Autoformat (buffer)
  <leader>ud          Diagnostics
  <leader>un          Dismiss all notifications
  <leader>uz          Zen mode (Snacks)
  <leader>uZ          Zoom current window  (also <leader>wm)

## Sessions (persistence.nvim — LazyVim)
  <leader>qs          Restore session for cwd
  <leader>ql          Restore last session (recovers closed buffers)
  <leader>qd          Don't save current session

## Custom (your mappings)
  <leader>rw          Toggle replace word

## Misc
  <leader>l           Lazy (plugin manager UI)
  <leader>cm          Mason (LSP/tool manager)
  <leader>qq          Quit all
  <leader>fn          New file
  <C-s>               Save file
  ZZ                  Save and quit
  ZQ                  Quit without saving
  ga                  Show byte/char info under cursor
  g;                  Last edit position (g, to go forward)
  g~ / gu / gU + iw   Toggle / lower / upper inner word
  :Inspect            Show highlight groups under cursor
  K                   Hover (or 'man' lookup outside LSP buffers)
]==]

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>KK",
        function()
          Snacks.win({
            text = cheatsheet,
            ft = "markdown",
            width = 0.85,
            height = 0.85,
            border = "rounded",
            title = " Cheatsheet ",
            title_pos = "center",
            wo = {
              wrap = false,
              cursorline = true,
              conceallevel = 2,
              spell = false,
            },
            bo = {
              modifiable = false,
              filetype = "markdown",
            },
            keys = {
              q = "close",
              ["<Esc>"] = "close",
            },
          })
        end,
        desc = "Cheatsheet (keybinds)",
      },
    },
  },
}
