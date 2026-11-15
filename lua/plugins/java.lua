return {
  { import = "lazyvim.plugins.extras.lang.java" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "java" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        jdtls = {},
      },
      setup = {
        jdtls = function()
          return true -- avoid duplicate servers
        end,
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "java-debug-adapter", "java-test" } },
  },
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          completion = {
            maxResults = 100, -- 0 = unlimited (default is 50)
          },
          format = {
            settings = {
              url = vim.fn.stdpath("config") .. "/formatter.xml",
              profile = "NoLimit",
            },
          },
        },
      })
      return opts
    end,
  },
}
