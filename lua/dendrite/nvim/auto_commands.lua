local M = {}

local config = require("dendrite.config")
local daemon_commands = require("dendrite.core.daemon_commands")

function M.setup()
	local group = vim.api.nvim_create_augroup("dendrite", { clear = true })

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

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function() end,
	})
end

return M
