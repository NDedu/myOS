-- ~/.config/nvim/lua/plugins/cheatsheet.lua
-- Floating cheatsheet window: <leader>kk

local cheatsheet = [==[
# Cheatsheet (condensed)

`q` / `<Esc>` close. `/pat` search.

## Motions
  w / e / b           Next word start / end / prev start
  ge                  Prev word end
  0 / ^ / $           Line start / first non-blank / end
  gg / G              File start / end
  {n}G                Go to line n
  M                   Middle of screen   (H/L are buffer prev/next)
  zz / zt / zb        Center / top / bottom this line
  %                   Matching bracket
  f{c} / t{c}         Find / till char in line   (; , to repeat)
  ( / )               Sentence start / end
  { / }               Paragraph up / down
  <C-d> / <C-u>       Half page down / up
  <C-o> / <C-i>       Jumplist back / forward

## Editing
  ciw / caw / ci"     Change inner / a word / inside quotes
  diw / yiw           Delete / yank inner word
  >> / <<             Indent / dedent
  J                   Join with line below
  u / <C-r>           Undo / redo
  .                   Repeat last change
  <C-a> / <C-x>       Increment / decrement number

## Text objects (with d / c / y / v)
  iw aw  i" a"  i( a(  i{ a{  i[ a[  it at  ip ap

## Buffers / Windows
  H / L  (S-h S-l)    Prev / next buffer
  <leader>bd          Delete buffer
  <C-w>s / <C-w>v     Split horizontal / vertical
  <C-h/j/k/l>         Move between windows
  <C-w>=              Equalize sizes

## Find (Snacks picker)
  <leader><space>     Find files (root)
  <leader>fr          Recent files
  <leader>,           Buffers
  <leader>/           Grep project
  <leader>sw          Grep word under cursor
  <leader>sb          Lines in buffer
  <leader>sR          Resume last picker

## LSP
  gd / gr             Definition / references
  K                   Hover (twice to enter float)
  <leader>ca          Code action
  <leader>cr          Rename
  <leader>cf          Format
  ]d / [d             Next / prev diagnostic
  <leader>cd          Line diagnostics

## Search & Replace
  /pat   n / N        Search   next / prev
  *                   Search word under cursor
  :%s/old/new/g       Replace in file
  :'<,'>s/old/new/g   Replace in selection
  <leader>sr          grug-far (project find/replace)

## Comments / Surround
  gcc                 Toggle comment line
  gc{motion}          Comment over motion
  gsa{motion}{c}      Add surround
  gsd{c}              Delete surround
  gsr{old}{new}       Replace surround

## Git
  <leader>gg          LazyGit
  ]h / [h             Next / prev hunk
  <leader>ghs         Stage hunk
  <leader>ghp         Preview hunk
  <leader>gb          Blame line

## Explorer / Terminal
  <leader>e           Explorer (root)
  <leader>ft          Terminal (root)
  <C-/>               Toggle terminal
  <Esc><Esc>          Term → normal mode

## Clipboard / Registers
  "+y / "+p           System clipboard yank / paste
  "0p                 Paste last yank (not delete)
  "_d                 Delete to black hole

## Macros
  q{a} ... q          Record into register a
  @{a}  /  @@         Replay  /  replay last

## Misc
  <C-s>               Save
  ZZ / ZQ             Save+quit / quit no save
  <leader>qq          Quit all
  <leader>qs / <leader>ql   Restore session (cwd / last)

## Custom
  <leader>rw          Toggle replace word

]==]

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>kk",
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
