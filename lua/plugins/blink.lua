return {
  "saghen/blink.cmp",
  opts = {
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
