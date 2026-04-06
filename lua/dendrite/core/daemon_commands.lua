local M = {}
local daemon = require("dendrite.core.daemon")

--- Start the Dendrite daemon process with a vault path
--- @param path string the full path to the vault directory to initialize
--- @param templates string directory containing note templates 
function M.init_vault(path, templates)
	daemon.request("initialize", {
		vaultPath = path,
    templateDirectory = templates,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: Failed to initialize vault: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.notify("Daemon Vault initialized successfully at: " .. path, vim.log.levels.INFO)
			end
		end)
	end)
end

--- Create a new note with the given title, template, and path.
--- @param title string the title of the note to create
--- @param template_name string the name of the template to use for the note
--- @param dir string the directory path where the note should be created
function M.create(title, template_name, dir)
	daemon.request("create_note", {
		title = title,
		templateName = template_name,
		directory = dir,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.cmd.edit(response.result)
			end
		end)
	end)
end

return M
