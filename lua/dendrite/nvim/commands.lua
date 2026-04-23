local M = {}

local daemon_commands = require("dendrite.core.daemon_commands")
function M.setup()
	vim.api.nvim_create_user_command("DendriteRebuild", function()
		daemon_commands.rebuild_index()
	end, { desc = "Rebuild the Dendrite index" })
end

return M
