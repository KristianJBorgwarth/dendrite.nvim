local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.selector(resource, on_select)
	pickers
		.new({}, {
			prompt_title = "select resource",
			finder = finders.new_table({ results = resource }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()[1]
					on_select(selection)
				end)
				return true
			end,
		})
		:find()
end

function M.backink_viewer(backlinks)
	pickers
		.new({}, {
			prompt_title = "backlinks",
			finder = finders.new_table({
				results = backlinks,
				entry_maker = function(bl)
					return {
						value = bl,
						display = bl.slug,
						ordinal = bl.slug,
						path = bl.path,
						lnum = bl.line,
						col = bl.col,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.grep_previewer({}),
		})
		:find()
end

function M.search(search_callback)
	pickers.new({}, {
		prompt_title = "search notes",
		finder = finders.new_dynamic({
			fn = search_callback,
		}),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry().value
				vim.cmd("edit " .. selection.path)
			end)
			return true
		end,
	})
end

function M.input(prompt)
	local input = vim.fn.input(prompt)
	return input
end

return M
