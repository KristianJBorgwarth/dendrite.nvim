local M = {}

local config = require("dendrite.config")
local actions = require("dendrite.nvim.actions")
local daemon = require("dendrite.daemon.daemon")

function M.setup(options)
	config.setup(options)
	daemon.start({ "/home/krjb/projects/dendrite.daemon/dendrite" })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			daemon.stop()
		end,
	})
	daemon.request("initialize", {
		vaultPath = config.options.vault,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Failed to initialize Dendrite Daemon: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.notify("Dendrite Daemon initialized successfully", vim.log.levels.INFO)
			end
		end)
	end)
end

function M.new_note(template_name, root_dir, fm_vars)
	actions.new_note(template_name, root_dir, fm_vars)
end

function M.daily_note()
	actions.daily_note()
end

function M.scratch_note()
	actions.new_scratch_note()
end

function M.search_frontmatter(keys)
	actions.search_frontmatter(keys)
end

return M
