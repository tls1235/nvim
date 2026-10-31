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
    },
    init = function()
      local orig = {}

      local function is_razor(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        return name:match("%.cshtml$") ~= nil or name:match("%.razor$") ~= nil
      end

      local function set_formatting(client, enabled)
        local caps = client.server_capabilities
        orig[client.id] = orig[client.id]
          or {
            format = caps.documentFormattingProvider,
            range = caps.documentRangeFormattingProvider,
          }
        caps.documentFormattingProvider = enabled and orig[client.id].format or false
        caps.documentRangeFormattingProvider = enabled and orig[client.id].range or false
      end

      vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter" }, {
        callback = function(args)
          for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn" })) do
            set_formatting(client, not is_razor(args.buf))
          end
        end,
      })
    end,
  },
}
