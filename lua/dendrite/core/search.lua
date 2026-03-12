local frontmatter = require("dendrite.core.frontmatter")
local vault = require("dendrite.core.vault")

local M = {}

--- Search notes for a full-text query (case-insensitive).
---@param query string the search string
---@param vault_root string the root directory of the vault
---@return table list of file paths whose content matches the query
function M.search_notes(query, vault_root)
  assert(type(query) == "string", "query must be a string")
  assert(type(vault_root) == "string", "vault_root must be a string")

  local results = {}
  for _, path in ipairs(vault.list_notes(vault_root)) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      if content:lower():find(query:lower(), 1, true) then
        table.insert(results, path)
      end
    end
  end
  return results
end

--- Search notes by tag (matches against frontmatter tags array).
---@param tag string the tag to search for
---@param vault_root string the root directory of the vault
---@return table list of file paths whose frontmatter tags contain the given tag
function M.search_by_tag(tag, vault_root)
  assert(type(tag) == "string", "tag must be a string")
  assert(type(vault_root) == "string", "vault_root must be a string")

  local results = {}
  for _, path in ipairs(vault.list_notes(vault_root)) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local data = frontmatter.parse(content)
      if data and type(data.tags) == "table" then
        for _, t in ipairs(data.tags) do
          if t == tag then
            table.insert(results, path)
            break
          end
        end
      end
    end
  end
  return results
end

--- Search notes by date prefix (matches against frontmatter created field).
--- Pass a date prefix like "2024-01" to match all notes created in January 2024.
---@param date string ISO 8601 date prefix to match against the created field
---@param vault_root string the root directory of the vault
---@return table list of file paths whose frontmatter created field starts with the given date
function M.search_by_date(date, vault_root)
  assert(type(date) == "string", "date must be a string")
  assert(type(vault_root) == "string", "vault_root must be a string")

  local results = {}
  for _, path in ipairs(vault.list_notes(vault_root)) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      local data = frontmatter.parse(content)
      if data and type(data.created) == "string" then
        if data.created:sub(1, #date) == date then
          table.insert(results, path)
        end
      end
    end
  end
  return results
end

return M
