local M = {}

local config = require("dendrite.config")
local actions = require("dendrite.nvim.actions")
local daemon = require("dendrite.core.daemon")
local daemon_commands = require("dendrite.core.daemon_commands")
local auto_commands = require("dendrite.nvim.auto_commands")
local commands = require("dendrite.nvim.commands")

function M.setup(options)
	config.setup(options)
	local daemon_path = jit.os == "OSX" and vim.fn.expand("/usr/local/bin/dendrite")
		or vim.fn.expand("~/.local/bin/dendrite")
	daemon.start(vim.fn.expand(daemon_path))
	daemon_commands.init_vault(config.options)
	auto_commands.setup()
	commands.setup()
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

function M.goto_link()
	actions.goto_link()
end

return M
