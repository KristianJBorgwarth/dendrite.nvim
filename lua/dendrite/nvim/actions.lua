local M = {}

local note = require("dendrite.core.note")
local config = require("dendrite.config")
local vault = require("dendrite.core.vault")
local ui = require("dendrite.core.ui")

function M.new_note(template_name, root_dir)
  local dirs = vault.list_directories(root_dir, 5)
  local template_path = config.options.templates_dir .. "/" .. template_name .. ".md"

  if not vault.file_exists(template_path) then
    error("Template not found: " .. template_path)
  end

  local template = vault.read_file(template_path)

  local title = ui.prompt("Enter Note Title:")
  if not title or title == "" then return end

  ui.selector(dirs, function(selected_dir)
    local path, wasCreated = note.create_note(title, template, selected_dir, {})
    vim.cmd.edit(path)
  end)
end

return M
