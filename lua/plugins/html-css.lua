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

local function strip(rel)
  rel = rel:gsub("^~/", "")
  rel = rel:gsub("^/", "")
  return rel
end

local function resolve(href, buf)
  if href:match("^https?://") or href:match("^//") then
    return "remote"
  end
  local root = vim.fs.root(buf, ".git") or vim.uv.cwd()
  local rel = href:gsub("[?#].*$", "")
  local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
  local candidates = {
    vim.fs.normalize(buf_dir .. "/" .. rel),
    root .. "/wwwroot/" .. strip(rel),
    root .. "/" .. strip(rel),
  }
  for _, path in ipairs(candidates) do
    if vim.uv.fs_stat(path) then
      return path
    end
  end
  return "NOT FOUND"
end

-- links from the buffer, falling back to _Layout.cshtml
local function linked_hrefs(buf)
  local hrefs, style_blocks = scan(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
  local source = "this buffer"
  if #hrefs == 0 then
    local root = vim.fs.root(buf, ".git") or vim.uv.cwd()
    local layout = vim.fs.find("_Layout.cshtml", { path = root, type = "file", limit = 1 })[1]
    if layout then
      hrefs, style_blocks = scan(vim.fn.readfile(layout))
      source = layout
    end
  end
  return hrefs, style_blocks, source
end

-- hand the resolved local files to nvim-html-css for this buffer
local function feed_plugin(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local hrefs = linked_hrefs(buf)
  local files = {}
  for _, href in ipairs(hrefs) do
    local path = resolve(href, buf)
    if path ~= "remote" and path ~= "NOT FOUND" then
      table.insert(files, path)
    end
  end
  if #files == 0 then
    return
  end
  local ok, err = pcall(function()
    local fetcher = require("html-css.fetcher")
    local cache = require("html-css.cache")
    for _, path in ipairs(files) do
      fetcher:fetch(path, buf, false)
    end
    cache:link_sources(buf, files)
  end)
  if not ok then
    vim.notify("html-css feed failed: " .. tostring(err), vim.log.levels.WARN)
  end
end

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
    },
    init = function()
      vim.treesitter.language.register("html", "razor")

      -- feed linked CSS every time a view is entered, opened, or saved
      vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWritePost" }, {
        pattern = { "*.cshtml", "*.razor" },
        callback = function(args)
          vim.defer_fn(function()
            feed_plugin(args.buf)
          end, 300)
        end,
      })

      -- re-read linked CSS for all open views when a .css file is saved
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.css",
        callback = function()
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(b) then
              local name = vim.api.nvim_buf_get_name(b)
              if name:match("%.cshtml$") or name:match("%.razor$") then
                feed_plugin(b)
              end
            end
          end
        end,
      })

      vim.api.nvim_create_user_command("CssLinks", function()
        local buf = vim.api.nvim_get_current_buf()
        local hrefs, style_blocks, source = linked_hrefs(buf)
        local out = { "Stylesheets from " .. source .. ":" }
        for _, href in ipairs(hrefs) do
          table.insert(out, string.format("  %s -> %s", href, resolve(href, buf)))
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
