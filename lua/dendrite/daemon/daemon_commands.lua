local M = {}
local daemon = require("dendrite.daemon.daemon")

function M.create_note(title, template_name, path)
  daemon.request("create_note", {
    title = title,
    template_name = template_name,
    path = path,
  }, function(response)
    vim.schedule(function()
      if response.error then
        vim.notify("Failed to create note: " .. response.error.message, vim.log.levels.ERROR)
      else
        vim.cmd.edit(response.result.path)
      end
    end)
  end)
end

return M
