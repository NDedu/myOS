-- Show hidden files. The tree (<leader>e) shows dotfiles (.gitignore, .env) and gitignored files, all but
-- the .git folder; file search and grep show dotfiles, and Alt+i in them adds the gitignored ones
return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_ignored = false,
          never_show = { ".git" },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true },
          grep = { hidden = true },
        },
      },
    },
  },
}
