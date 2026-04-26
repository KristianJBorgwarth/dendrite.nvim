local M = {}

local daemon_commands = require("dendrite.core.daemon_commands")
local actions = require("dendrite.nvim.actions")

function M.setup()

	vim.api.nvim_create_user_command("DendriteRebuild", function()
		daemon_commands.rebuild_index()
	end, { desc = "Rebuild the Dendrite index" })

  vim.api.nvim_create_user_command("DendriteBacklinks", function()
    actions.view_backlinks()
  end, { desc = "View backlinks for the current note" })
end

return M
