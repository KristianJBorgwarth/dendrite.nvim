local M = {}

local note = require("dendrite.core.note")
local config = require("dendrite.config")
local vault = require("dendrite.core.vault")
local ui = require("dendrite.nvim.ui")
local utilities = require("dendrite.nvim.utilities")

function M.new_note(template_name, root_dir)
  local vault_root = config.options.vault
  local full_root = vault_root .. "/" .. root_dir

  local dirs = vault.list_directories(full_root, 5)

  local template_path =
      vim.fn.expand(config.options.templates_dir) .. "/" .. template_name .. ".md"

  if not vault.file_exists(template_path) then
    error("Template not found: " .. template_path)
  end

  local template = vault.read_file(template_path)

  local title = ui.input("Enter Note Title:")
  if not title or title == "" then return end

  local display_dirs = utilities.format_dirs_to_display(dirs, vault_root)

  ui.selector(display_dirs, function(selected_relative)
    local selected_full_dir = vault_root .. "/" .. selected_relative
    local path, wasCreated = note.create_note(title, template, selected_full_dir, {})
    vim.cmd.edit(path)
  end)
end

return M
