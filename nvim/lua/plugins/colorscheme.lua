-- ~/.config/nvim/lua/plugins/colorscheme.lua
-- Rose Pine colorscheme configuration

return {
  "rose-pine/neovim",
  name = "rose-pine",
  priority = 1000, -- Load colorscheme early
  config = function()
    require("rose-pine").setup({
      variant = "moon", -- "main" (default), "moon" (Midnight), or "dawn"
      dark_variant = "moon",
      disable_background = true, -- Disable the background color
      styles = {
        italic = true,
        transparency = true,
      },
    })
    
    -- Set colorscheme
    vim.cmd("colorscheme rose-pine")
  end,
}