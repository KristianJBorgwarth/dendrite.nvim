local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")
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

function M.search(prompt_title, search_fn)
	local results_cache = {}
	local request_id = 0
	local current_picker = nil

	local entry_maker_fn = function(entry)
		return {
			value = entry,
			display = entry.title,
			ordinal = entry.title,
			path = entry.path,
		}
	end

	current_picker = pickers.new({}, {
		prompt_title = prompt_title,
		finder = finders.new_dynamic({
			fn = function(prompt)
				if not prompt or prompt == "" then
					return {}
				end

				if results_cache[prompt] then
					local r = results_cache[prompt]
					results_cache[prompt] = nil
					return r
				end

				request_id = request_id + 1
				local my_id = request_id

				search_fn(prompt, function(results)
					if my_id ~= request_id or not current_picker then
						return
					end
					results_cache[prompt] = results
					current_picker._on_lines(nil, nil, nil, 0, 1)
				end)

				return {}
			end,
			entry_maker = entry_maker_fn,
		}),
		sorter = sorters.empty(),
		previewer = conf.file_previewer({}),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry().value
				vim.cmd("edit " .. selection.path)
			end)
			return true
		end,
	})
	current_picker:find()
end

function M.input(prompt)
	local input = vim.fn.input(prompt)
	return input
end

return M
