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

	local ok, cmp = pcall(require, "cmp")
	if ok then
		cmp.register_source("dendrite", require("dendrite.cmp_source").new())

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "markdown",
			callback = function()
				local global_sources = vim.deepcopy(require("cmp.config").get().sources or {})
				cmp.setup.buffer({
					sources = vim.list_extend({ { name = "dendrite", priority = 150 } }, global_sources),
				})
			end,
		})
	else
		vim.notify("Dendrite: nvim-cmp not found, completion will not work", vim.log.levels.WARN)
	end
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
