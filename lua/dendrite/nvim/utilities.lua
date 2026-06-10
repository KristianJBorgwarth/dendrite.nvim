local M = {}

local config = require("dendrite.config")

function M.format_dirs_to_display(dirs, display_root)
	local display_dirs = {}
	for _, dir in ipairs(dirs) do
		local relative_path = dir:gsub("^" .. vim.pesc(display_root) .. "/?", "")
		table.insert(display_dirs, relative_path)
	end
	return display_dirs
end

function M.strip_dirs_from_path(path)
  return path:match("([^/]+)$")
end

function M.get_template_path(template_name)
	local templates_dir = vim.fn.expand(config.options.templates_dir)
	return templates_dir .. "/" .. template_name .. ".md"
end

function M.link_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local patterns = { "%[%[.-%]%]", "%[.-%]%(.-%)" }
	local init = 1
	while true do
		local best_s, best_e, best_match
		for _, pat in ipairs(patterns) do
			local s, e = line:find(pat, init)
			if s and (not best_s or s < best_s) then
				best_s, best_e = s, e
				best_match = line:sub(s, e)
			end
		end
		if not best_s then
			return nil
		end
		if col >= best_s and col <= best_e then
			return best_match
		end
		init = best_e + 1
	end
end

return M
