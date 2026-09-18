-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>rw", function()
  local old = vim.fn.input("Search: ")
  if old == "" then return end
  local new = vim.fn.input("Replace with: ")
  local cmd = "%s/\\<" .. vim.fn.escape(old, "/\\") .. "\\>/" .. vim.fn.escape(new, "/\\") .. "/gIc"
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify("Pattern not found: " .. old, vim.log.levels.WARN)
  end
end, { desc = "Replace word in file" })
