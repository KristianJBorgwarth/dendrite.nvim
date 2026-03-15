local M = {}

local note = require("dendrite.core.note")
local config = require("dendrite.config")
local vault = require("dendrite.core.vault")
local ui = require("dendrite.nvim.ui")
local utilities = require("dendrite.nvim.utilities")

--- Create a new note from a template, prompting the user for the note title and target directory.
--- @param template_name string the name of the template to use (without .md extension)
--- @param root_dir string the root directory within the vault where the note should be created (relative to the vault root)
--- @param fm_vars table a collection of variables for template rendering, where keys are variable names and values are their replacements
function M.new_note(template_name, root_dir, fm_vars)
  local vault_root = config.options.vault
  local full_root = vault_root .. "/" .. root_dir

  local dirs = vault.list_directories(full_root, 5)

  --- move template handling into core instead of here
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
    local path = note.create_note(title, template, selected_full_dir, {})
    vim.cmd.edit(path)
  end)
end

function M.daily_note()
  local title = os.date("%Y-%m-%d")
  local template_name = config.options.daily_notes.template_name
  local template_path = vim.fn.expand(config.options.templates_dir) .. "/" .. template_name .. ".md"

  if not vault.file_exists(template_path) then
    error("Daily note template not found: " .. template_path)
  end

  local template = vault.read_file(template_path)

  local path = note.create_not(
    title,
    template,
    config.options.daily_notes.dir,
    {})

  vim.cmd.edit(path)
end

return M
