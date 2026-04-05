local M = {}

local note = require("dendrite.core.note")
local config = require("dendrite.config")
local vault = require("dendrite.core.vault")
local ui = require("dendrite.nvim.ui")
local utilities = require("dendrite.nvim.utilities")
local daemon_commands = require("dendrite.daemon.commands")

function M.daily_note()
	local title = os.date("%Y-%m-%d")
	local template_path = utilities.get_template_path(config.options.daily_notes.template_name)

	local path =
		note.create_note(title, template_path, config.options.vault .. "/" .. config.options.daily_notes.dir, {})

	vim.cmd.edit(path)
end

function M.new_scratch_note()
	local title = ui.input("Enter Scratch Note Title:")
	if not title or title == "" then
		return
	end

	local template_path = utilities.get_template_path(config.options.scratch_notes.template_name)

  daemon_commands.create(title, template_path, config.options.vault .. config.options.scratch_notes.dir .. "/" .. note._slugify(title) .. ".md")
end

function M.create_note(template_name, root_dir)
	local vault_root = config.options.vault
	local full_root = vault_root .. "/" .. root_dir

	local dirs = vault.list_directories(full_root, 5)
  local template_path = utilities.get_template_path(template_name)

	local title = ui.input("Enter Note Title:")
	if not title or title == "" then
		return
	end

	local display_dirs = utilities.format_dirs_to_display(dirs, vault_root)

	if #display_dirs == 0 then
		local selected_full_dir = vault_root .. "/" .. root_dir
		daemon_commands.create(title, template_path, selected_full_dir .. "/" .. note._slugify(title) .. ".md")
		return
	end

	ui.selector(display_dirs, function(selected_relative)
		local selected_full_dir = vault_root .. "/" .. selected_relative
		daemon_commands.create(title, template_path, selected_full_dir .. "/" .. note._slugify(title) .. ".md")
	end)
end

return M
