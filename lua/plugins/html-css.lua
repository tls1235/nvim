return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "html", "css" })
    end,
  },
  {
    "Jezda1337/nvim-html-css",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      enable_on = { "html", "cshtml", "razor" },
      style_sheets = {
        "./wwwroot/css/site.css",
        -- add your other project CSS files here
      },
    },
    init = function()
      vim.treesitter.language.register("html", "razor")
      vim.api.nvim_create_user_command("CssLinks", function()
        local root = vim.fs.root(0, ".git") or vim.uv.cwd()

        local function scan(lines)
          local text = table.concat(lines, "\n")
          local hrefs = {}
          for tag in text:gmatch("<link[^>]*>") do
            if tag:lower():find("stylesheet", 1, true) then
              local href = tag:match('href%s*=%s*"([^"]+)"') or tag:match("href%s*=%s*'([^']+)'")
              if href then
                table.insert(hrefs, href)
              end
            end
          end
          local _, style_blocks = text:gsub("<style[%s>]", "")
          return hrefs, style_blocks
        end

        local function resolve(href)
          if href:match("^https?://") or href:match("^//") then
            return "remote"
          end
          local rel = href:gsub("[?#].*$", "")
          local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
          local candidates = {
            vim.fs.normalize(buf_dir .. "/" .. rel),
            root .. "/wwwroot/" .. rel:gsub("^~/", ""):gsub("^/", ""),
            root .. "/" .. rel:gsub("^~/", ""):gsub("^/", ""),
          }
          for _, path in ipairs(candidates) do
            if vim.uv.fs_stat(path) then
              return path
            end
          end
          return "NOT FOUND"
        end

        local hrefs, style_blocks = scan(vim.api.nvim_buf_get_lines(0, 0, -1, false))
        local source = "this buffer"

        if #hrefs == 0 then
          local layout = vim.fs.find("_Layout.cshtml", { path = root, type = "file", limit = 1 })[1]
          if layout then
            hrefs, style_blocks = scan(vim.fn.readfile(layout))
            source = layout
          end
        end

        local out = { "Stylesheets from " .. source .. ":" }
        for _, href in ipairs(hrefs) do
          table.insert(out, string.format("  %s -> %s", href, resolve(href)))
        end
        if #hrefs == 0 then
          table.insert(out, "  (no <link rel=stylesheet> found)")
        end
        table.insert(out, string.format("Inline <style> blocks: %d", style_blocks))
        vim.notify(table.concat(out, "\n"))
      end, {})
    end,
  },
}
