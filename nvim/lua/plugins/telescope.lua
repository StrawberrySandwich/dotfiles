-- ~/.config/nvim/lua/plugins/telescope.lua
-- Telescope fuzzy finder configuration

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    
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
        file_ignore_patterns = {
          "^bin/",
          "bin/",
          "^obj/",
          "obj/",
          "^wwwroot/",
          "wwwroot/",
          "%.git/",
          "node_modules/",
        },
        prompt_prefix = "🔍 ",
        selection_caret = " ",
        path_display = { "truncate" },
        layout_strategy = "vertical",
        layout_config = {
          height = 0.9,
          width = 0.8,
          preview_cutoff = 20,
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
        preview = {
          filesize_limit = 0.1, -- MB
          timeout = 250,
          treesitter = false, -- Disable treesitter in preview to prevent formatting
        },
        mappings = {
          i = {
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = {
            ["<esc>"] = actions.close,
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["q"] = actions.close,
          },
        },
      },
      --pickers = {
      --  find_files = {
      --    theme = "dropdown",
      --    previewer = false,
      --  },
      --  buffers = {
      --    theme = "dropdown",
      --    previewer = false,
      --    initial_mode = "normal",
      --  },
      --},
    })
    
    -- Load telescope extensions
    pcall(require("telescope").load_extension, "fzf")
  end,
}