-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>cco", function()
  if vim.opt.colorcolumn:get()[1] then
    vim.opt.colorcolumn = ""
    print("ColorColumn OFF")
  else
    vim.opt.colorcolumn = "80"
    print("ColorColumn ON")
  end
end, { desc = "Toggle ColorColumn" })
