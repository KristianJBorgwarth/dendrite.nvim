local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local async = require("plenary.async")

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

function M.search(prompt_title, search_fn)
	pickers
		.new({}, {
			prompt_title = prompt_title,
			finder = finders.new_dynamic({
				fn = async.wrap(function(prompt, cb)
					if not prompt or prompt == "" then
						cb({})
						return
					end
					search_fn(prompt, cb)
				end, 2),
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.title,
						ordinal = entry.title,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry().value
					vim.cmd("edit " .. selection.path)
				end)
				return true
			end,
		})
		:find()
end

function M.input(prompt)
	local input = vim.fn.input(prompt)
	return input
end

return M
