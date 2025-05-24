-- Ensure Lazy.nvim is loaded
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "rose-pine/neovim",
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },  -- Required dependency
})

-- Set Rose Pine Midnight as the theme
require("rose-pine").setup({
  variant = "moon",  -- "main" (default), "moon" (Midnight), or "dawn"
  dark_variant = "moon",
  disable_background = true,  -- Disable the background color
})
vim.cmd("colorscheme rose-pine")

vim.g.mapleader = ","   -- Set leader to comma
vim.g.maplocalleader = ","  -- Also set local leader to comma
vim.opt.number = true
--vim.opt.relativenumber = true

-- Load Telescope
local telescope = require("telescope")

telescope.setup({
    defaults = {
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
        },
        prompt_prefix = "🔍 ",
        selection_caret = " ",
        path_display = { "truncate" },
        layout_strategy = "vertical", -- Set default layout to vertical
        layout_config = {
            height = 0.9,  -- 90% of the screen height
            width = 0.8,   -- 80% of the screen width
            preview_cutoff = 20,
            prompt_position = "top",
        },
        sorting_strategy = "ascending", -- Makes results appear top-to-bottom
    },
})

-- Keybindings for Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})  -- Find files
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})   -- Grep text
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})     -- List open buffers
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})   -- Find help
