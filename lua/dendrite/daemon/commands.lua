local M = {}
local daemon = require("dendrite.daemon.daemon")

--- Create a new note with the given title, template, and path.
--- @param title string the title of the note to create
--- @param template_name string the name of the template to use for the note
--- @param path string the full path where the note should be created (including the filename)
function M.create(title, template_name, path)
  daemon.request("create_note", {
    title = title,
    templatePath = template_name,
    path = path,
  }, function(response)
    vim.schedule(function()
      if response.error then
        vim.notify("Failed to create note: " .. response.error.message, vim.log.levels.ERROR)
      else
        vim.cmd.edit(response.result)
      end
    end)
  end)
end

return M
