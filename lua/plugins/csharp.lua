vim.filetype.add({
  extension = { cshtml = "razor", razor = "razor" },
})

return {
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = { "roslyn", "csharpier", "html-lsp" },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {},
    config = function(_, opts)
      vim.lsp.config("roslyn", {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
          },
          ["csharp|completion"] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
          },
        },
      })
      require("roslyn").setup(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        emmet_language_server = { enabled = false },
      },
      html = {
        filetypes = { "html", "razor" },
        init_options = { provideFormatter = true },
        settings = {
          html = {
            format = {
              wrapLineLength = 0,
            },
          },
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local name = vim.api.nvim_buf_get_name(args.buf)
          if client and client.name == "roslyn" and name:match("%.cshtml$") then
            vim.schedule(function()
              vim.lsp.buf_detach_client(args.buf, client.id)
            end)
          end
        end,
      })
    end,
  },
}
