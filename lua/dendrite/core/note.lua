local M = {}

--- Render a template string by replacing placeholders with provided variables.
---@param template string the template file content as a string
---@param vars table key-value pairs. Keys correspond to placeholders in the template, and values are the replacements.
function M._render_template(template, vars)
  return (template:gsub("{{(.-)}}", function(key)
    if vars[key] == nil then
      return nil
    end
    return vars[key]
  end))
end

--- Convert a title into a URL-friendly slug.
---@param title string the title to be converted into a slug
---@return string a URL-friendly slug derived from the title
function M._slugify(title)
  return (
    title
    :lower()
    :gsub("%s+", "-")
    :gsub("[^%w%-]", "")
    :gsub("^-+", "")
    :gsub("-+$", "")
  )
end

--- Validate the parameters for creating a note.
---@param title string the title of the note, must be a string
---@param template string the template content as a string, must be a string
---@param path string the directory path where the note will be created, must be a string
---@param vars table a collection of variables for template rendering, must be a table
function M._validate_note_params(title, template, path, vars)
  assert(type(title) == "string", "title must be a string")
  assert(type(template) == "string", "template must be a string")
  assert(type(path) == "string", "path must be a string")
  assert(type(vars) == "table", "vars must be a table")
end

--- Create a new note by rendering a template with provided variables and saving it to the specified path.
---@param title string the title of the note, used to generate the file name
---@param template string the template content as a string, used to generate the note content
---@param path string the directory path where the note will be created
---@param vars table a collection of variables for template rendering, where keys are variable names and values are their replacements
---@return string the file path of the created note
---@return boolean created true if the note was created, false if it already existed
function M.create_note(title, template, path, vars)
  M._validate_note_params(title, template, path, vars)
  local note_content = M._render_template(template, vars)

  local file_name = M._slugify(title)
  local file_path = path .. "/" .. file_name .. ".md"

  local file_exists = io.open(file_path, "r")
  if file_exists then
    file_exists:close()
    return file_path, false
  end

  local file = io.open(file_path, "w")
  if not file then
    error("Could not create note at: " .. file_path)
  end

  file:write(note_content)
  file:close()

  return file_path, true
end

return M
