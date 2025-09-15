return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        progress = {
          enabled = true,
          format = function(progress)
            if not progress.token then
              return nil
            end
            return progress
          end,
        },
      },
      presets = {
        lsp_doc_border = true,
      },
    },
  },
}
