-- ~/.config/nvim/lua/config/options.lua
-- Core Neovim settings

local opt = vim.opt
local g = vim.g

-- Leader keys
g.mapleader = ","
g.maplocalleader = ","

-- Line numbers
opt.number = true
-- opt.relativenumber = true  -- Uncomment if you want relative numbers

-- Add any other global options here
-- opt.tabstop = 2
-- opt.shiftwidth = 2
-- opt.expandtab = true