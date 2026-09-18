return {
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      local disabled = { text = true, markdown = true }
      return not disabled[vim.bo.filetype]
    end,
  },
}
