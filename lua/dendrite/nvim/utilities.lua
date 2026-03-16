local M = {}

local config = require("dendrite.config")

--- Formats a list of absolute directory paths to be relative to the display root.
--- @param dirs table A list of absolute directory paths.
--- @param display_root string The root directory to which the paths should be made relative.
--- @return table A list of formatted directory paths relative to the display root.
function M.format_dirs_to_display(dirs, display_root)
  local display_dirs = {}
  for _, dir in ipairs(dirs) do
    local relative_path = dir:gsub("^" .. vim.pesc(display_root) .. "/?", "")
    table.insert(display_dirs, relative_path)
  end
  return display_dirs
end

function M.get_template_path(template_name)
  local templates_dir = vim.fn.expand(config.options.templates_dir)
  return templates_dir .. "/" .. template_name .. ".md"
end



return M
