local M = {}

local daemon_commands = require("dendrite.core.daemon_commands")
local actions = require("dendrite.nvim.actions")

function M.setup()
	vim.api.nvim_create_user_command("DendriteRebuild", function()
		daemon_commands.rebuild_index()
	end, { desc = "Rebuild the Dendrite index" })

  vim.api.nvim_create_user_command("Drb", function()
    daemon_commands.rebuild_index()
  end, { desc = "Rebuild the Dendrite index (short)" })

	vim.api.nvim_create_user_command("DendriteBacklinks", function()
		actions.view_backlinks()
	end, { desc = "View backlinks for the current note" })

  vim.api.nvim_create_user_command("Dbl", function()
    actions.view_backlinks()
  end, { desc = "View backlinks for the current note (short)" })

	vim.api.nvim_create_user_command("DendriteSearchTags", function()
		actions.search_notes_by_tag()
	end, { desc = "Search for notes by tag" })

	vim.api.nvim_create_user_command("Dts", function()
		actions.search_notes_by_tag()
	end, { desc = "View backlinks for the current note (short)" })
end

return M
