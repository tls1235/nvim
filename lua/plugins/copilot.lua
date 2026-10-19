vim.g.copilot_enabled = false

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  keys = {
    {
      "<leader>z",
      function()
        vim.g.copilot_enabled = not vim.g.copilot_enabled
        vim.cmd(vim.g.copilot_enabled and "Copilot enable" or "Copilot disable")
        vim.notify("Copilot " .. (vim.g.copilot_enabled and "enabled" or "disabled"))
      end,
      desc = "Toggle Copilot",
    },
  },
  opts = {
    should_attach = function()
      return vim.g.copilot_enabled
    end,
    suggestion = {
      auto_trigger = true,
      debounce = 700,
      keymap = {
        accept = "<Tab>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    panel = { enabled = false },
  },
}
-- vim.g.copilot_enabled = false
--
-- return {
--   "zbirenbaum/copilot.lua",
--   event = "InsertEnter",
--   opts = {
--     should_attach = function()
--       return vim.g.copilot_enabled
--     end,
--     suggestion = {
--       auto_trigger = true,
--       debounce = 700,
--       keymap = {
--         accept = "<Tab>",
--         next = "<M-]>",
--         prev = "<M-[>",
--         dismiss = "<C-]>",
--       },
--     },
--     panel = { enabled = false },
--   },
--   config = function(_, opts)
--     require("copilot").setup(opts)
--
--     vim.keymap.set("n", "<leader>z", function()
--       vim.g.copilot_enabled = not vim.g.copilot_enabled
--       vim.cmd(vim.g.copilot_enabled and "Copilot enable" or "Copilot disable")
--       vim.notify("Copilot " .. (vim.g.copilot_enabled and "enabled" or "disabled"))
--     end, { desc = "Toggle Copilot" })
--   end,
-- }
