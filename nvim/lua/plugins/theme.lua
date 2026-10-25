-- Colorscheme: zenwritten with the warm (slightly lighter) dark background, the same colors as ghostty and lazygit
return {
  {
    "zenbones-theme/zenbones.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.zenwritten = { darkness = "warm" }
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "zenwritten",
    },
  }
}
