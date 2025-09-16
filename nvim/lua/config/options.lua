-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true

vim.opt.sidescrolloff = 30
vim.opt.colorcolumn = "80"

-- Use autocmd to override colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Soft overlay that works well with 75% opacity terminal
    vim.cmd("highlight ColorColumn guibg=#4a2f3d")  -- Muted version of your pink
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("highlight ColorColumn guibg=#4a2f3d")
  end,
})

vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1

local original_handler = vim.lsp.handlers["$/progress"]
vim.lsp.handlers["$/progress"] = function(_, result, ctx, ...)
  if not result or not result.token then
    return
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client and client.name == "roslyn" then
    return
  end

  if original_handler then
    return original_handler(_, result, ctx, ...)
  end
end
