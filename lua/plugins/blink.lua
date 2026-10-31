return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      providers = {
        lsp = {
          transform_items = function(_, items)
            if vim.bo.filetype ~= "razor" then
              return items
            end
            local seen = {}
            for _, item in ipairs(items) do
              if item.client_name == "roslyn" then
                seen[item.label] = true
              end
            end
            return vim.tbl_filter(function(item)
              return not (item.client_name == "html" and seen[item.label])
            end, items)
          end,
        },
      },
    },
    completion = {
      menu = {
        draw = {
          columns = {
            { "kind_icon", "label", "label_description", gap = 1 },
            { "source" },
          },
          components = {
            source = {
              text = function(ctx)
                return ctx.item.client_name or ctx.source_name
              end,
            },
          },
        },
      },
    },
  },
}
