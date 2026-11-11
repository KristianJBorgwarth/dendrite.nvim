local M = {}

local config = require("dendrite.config")
local vault = require("dendrite.core.utilities")
local ui = require("dendrite.nvim.ui")
local utilities = require("dendrite.nvim.utilities")
local daemon_commands = require("dendrite.core.daemon_commands")

function M.daily_note()
	local title = os.date("%Y-%m-%d")
	local daily = config.vault().daily_notes
	daemon_commands.create(title, daily.template_name, daily.dir)
end

function M.new_scratch_note()
	local title = ui.input("Enter Scratch Note Title:")
	if not title or title == "" then
		return
	end

	local scratch = config.vault().scratch_notes
	daemon_commands.create(title, scratch.template_name, scratch.dir)
end

function M.create_note(template_name, root_dir)
	local vault_root = config.vault().vault_path
	local full_root = vault_root .. "/" .. root_dir

	local dirs = vault.list_directories(full_root, 5)

	local title = ui.input("Enter Note Title:")
	if not title or title == "" then
		return
	end

	local display_dirs = utilities.format_dirs_to_display(dirs, vault_root)

	if #display_dirs == 0 then
		daemon_commands.create(title, template_name, root_dir)
		return
	end

	ui.selector(display_dirs, function(selected_relative)
		daemon_commands.create(title, template_name, selected_relative)
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
		ui.backink_viewer(backlinks)
	end)
end

function M.switch_vault()
	daemon_commands.list_vaults(function(vaults)
		if #vaults == 0 then
			vim.notify("No vaults registered", vim.log.levels.WARN)
			return
		end
		vim.ui.select(vaults, {
			prompt = "Select vault",
			format_item = function(v)
				local mark = v.name == config.active and "* " or "  "
				return mark .. v.name .. "  (" .. v.noteCount .. " notes)  " .. v.path
			end,
		}, function(choice)
			if not choice then
				return
			end
			config.adopt(choice.name, choice.path)
			daemon_commands.use_vault(choice.name, function()
				config.set_active(choice.name)
				vim.notify("Active vault: " .. choice.name, vim.log.levels.INFO)
			end)
		end)
	end)
end

function M.create_vault()
	local name = ui.input("Vault name: ")
	if not name or name == "" then
		return
	end
	local path = ui.input("Vault path (empty = " .. vim.fn.getcwd() .. "): ")
	if not path or path == "" then
		path = vim.fn.getcwd()
	end

	local vault = config.new_vault(name, path)
	daemon_commands.create_vault(vault, function()
		config.register(vault)
		config.set_active(name)
		vim.notify("Created vault '" .. name .. "' at " .. vault.vault_path, vim.log.levels.INFO)
	end)
end

function M.search_notes_by_tag()
  ui.search("search by tag", daemon_commands.search_notes_by_tag)
end

return M
