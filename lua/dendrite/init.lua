local M = {}

local config = require("dendrite.config")
local actions = require("dendrite.nvim.actions")
local daemon = require("dendrite.core.daemon")
local daemon_commands = require("dendrite.core.daemon_commands")

function M.setup(options)
	config.setup(options)
	daemon.start({ "/home/krjb/projects/dendrite.daemon/dendrite" })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			daemon.stop()
		end,
	})
  daemon_commands.init_vault(config.options.vault, config.options.template_dir)
end

function M.new_note(template_name, root_dir)
	actions.create_note(template_name, root_dir)
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
