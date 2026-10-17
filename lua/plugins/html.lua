-- return {
--   {
--     "neovim/nvim-lspconfig",
--     opts = {
--       servers = {
--         html = { init_options = { provideFormatter = false } },
--         cssls = { init_options = { provideFormatter = false } },
--         emmet_language_server = { enabled = false },
--       },
--     },
--   },
--   {
--     "mason-org/mason.nvim",
--     opts = { ensure_installed = { "html-lsp", "css-lsp", "emmet-language-server" } },
--   },
-- }
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        emmet_language_server = { enabled = false },
        html = {
          filetypes = { "html", "razor" },
          init_options = { provideFormatter = true },
        },
      },
    },
  },
}
