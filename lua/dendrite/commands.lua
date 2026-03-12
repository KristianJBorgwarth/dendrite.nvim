local core = require("dendrite.core.note")
local config = require("dendrite.config")

local M = {}

---comment create new note from template
---@param template_name string
function M.new_note(template_name)
end


function M.find_note()
  local vault = config.options.vault
  local notes = core.list_notes(vault)

  vim.ui.select(notes, {
    prompt = "Select a note:",
  }, function(choice)
    if choice then
      local note_path = vault .. "/" .. choice
      vim.cmd("edit " .. note_path)
    end
  end)

end
return M
