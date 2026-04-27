local M = {}

local config = require("dendrite.config")
local daemon_commands = require("dendrite.core.daemon_commands")
local daemon = require("dendrite.core.daemon")

function M.setup()
	local group = vim.api.nvim_create_augroup("dendrite", { clear = true })
	M._register_save_note(group)
	M._register_cmp_source()
  M._register_daemon_stop(group)
end

function M._register_daemon_stop(group)
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      daemon.stop()
    end,
  })
end

function M._register_save_note(group)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.md",
		callback = function(args)
			local path = vim.api.nvim_buf_get_name(args.buf)
			local vault_path = config.options.vault_path
			if not vim.startswith(path, vault_path .. "/") then
				return
			end
			daemon_commands.save_note(path)
		end,
	})
end

function M._register_cmp_source(group)
	local ok, cmp = pcall(require, "cmp")
	if ok then
		cmp.register_source("dendrite", require("dendrite.cmp_source").new())

		vim.api.nvim_create_autocmd("FileType", {
      group = group,
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

return M
