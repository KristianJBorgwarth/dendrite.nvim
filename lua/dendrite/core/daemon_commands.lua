local M = {}
local daemon = require("dendrite.core.daemon")

--- Start the Dendrite daemon process with a vault path
--- @param path string the full path to the vault directory to initialize
function M.init_vault(path)
	daemon.request("initialize", {
		vaultPath = path,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Failed to initialize vault: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.notify("Vault initialized successfully at: " .. path, vim.log.levels.INFO)
			end
		end)
	end)
end

--- Create a new note with the given title, template, and path.
--- @param title string the title of the note to create
--- @param template_path string the name of the template to use for the note
--- @param path string the full path where the note should be created (including the filename)
function M.create(title, template_path, path)
	daemon.request("create_note", {
		title = title,
		templatePath = template_path,
		path = path,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Failed to create note: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.cmd.edit(response.result)
			end
		end)
	end)
end

return M
