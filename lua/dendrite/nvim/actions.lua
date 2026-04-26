local M = {}

local config = require("dendrite.config")
local vault = require("dendrite.core.vault")
local ui = require("dendrite.nvim.ui")
local utilities = require("dendrite.nvim.utilities")
local daemon_commands = require("dendrite.core.daemon_commands")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

function M.daily_note()
	local title = os.date("%Y-%m-%d")
	local template_path = utilities.get_template_path(config.options.daily_notes.template_name)

	daemon_commands.create(title, template_path, config.options.daily_notes.dir)
end

function M.new_scratch_note()
	local title = ui.input("Enter Scratch Note Title:")
	if not title or title == "" then
		return
	end

	local template_path = utilities.get_template_path(config.options.scratch_notes.template_name)

	daemon_commands.create(title, template_path, config.options.scratch_notes.dir)
end

function M.create_note(template_name, root_dir)
	local vault_root = config.options.vault_path
	local full_root = vault_root .. "/" .. root_dir

	local dirs = vault.list_directories(full_root, 5)
	local template_path = utilities.get_template_path(template_name)

	local title = ui.input("Enter Note Title:")
	if not title or title == "" then
		return
	end

	local display_dirs = utilities.format_dirs_to_display(dirs, vault_root)

	if #display_dirs == 0 then
		daemon_commands.create(title, template_path, root_dir)
		return
	end

	ui.selector(display_dirs, function(selected_relative)
		daemon_commands.create(title, template_path, selected_relative)
	end)
end

function M.goto_link()
	local target = utilities.link_under_cursor()
	if not target then
		vim.notify("No wikilink found under cursor", vim.log.levels.WARN)
		return
	end

	daemon_commands.goto_note(target)
end

function M.view_backlinks()
	local current_file = vim.api.nvim_buf_get_name(0)
	if current_file == "" then
		vim.notify("No file is currently open", vim.log.levels.WARN)
	end

	daemon_commands.get_backlinks(current_file, function(backlinks)
		if #backlinks == 0 then
			vim.notify("No backlinks found for this note", vim.log.levels.INFO)
			return
		end
		pickers
			.new({}, {
				prompt_title = "Backlinks",
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
	end)
end

return M
