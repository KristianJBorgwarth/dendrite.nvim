local M = {}

--- Validate the parameters for resolving a link.
--- @param path string the file path component of the link, must be a string and should not include the .md extension
--- @param anchor string|nil the optional anchor component of the link, if present must be a string that is lowercase and contains only a-z, 0-9, and hyphens
--- @param vault_root string the root directory of the vault where the link should be resolved, must be a string
function M._validate_parameters(path, anchor, vault_root)
  assert(type(path) == "string", "link path must be a string")
  assert(type(vault_root) == "string", "vault_root must be a string")
  assert(not path:match("%.md$"), "link path should not include .md extension")
  if anchor ~= nil then
    assert(type(anchor) == "string", "anchor must be a string")
    assert(
      anchor:match("^[a-z0-9%-]+$"),
      "anchor must be lowercase and contain only a-z, 0-9, and hyphens"
    )
  end
end

--- Parse a link into its file path and optional anchor components.
--- @param link string the link to be parsed, which may include a markdown section (e.g., "note.md#section")
--- @return table a table containing the parsed file path and optional anchor, with keys "link_path" and "anchor"
function M._parse_link(link)
  assert(type(link) == "string", "link must be a string")
  local path, anchor = link:match("([^#]+)#?(.*)")
  if anchor == "" then anchor = nil end
  return {
    path = path,
    anchor = anchor
  }
end

--- Check if the resolved link exists as a file in the vault.
--- @param path string the resolved file path to check for existence
--- @return boolean true if the resolved link exists as a file in the vault, false otherwise
function M._link_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

--- Resolve a link to its corresponding file path within the vault and markdown section if present.
--- @param link string the link to be resolved, which may include a markdown section (e.g., "note.md#section")
--- @param vault_root string the root directory of the vault where the link should be resolved
--- @return table a table containing the resolved file path, optional anchor, and existence status, with keys "path", "anchor", and "exists"
function M.resolve_link(link, vault_root)
  local parsed = M._parse_link(link)
  M._validate_parameters(parsed.path, parsed.anchor, vault_root)

  local path = vault_root .. "/" .. parsed.path .. ".md"

  local exists = M._link_exists(path)

  return {
    path = path,
    anchor = parsed.anchor,
    exists = exists
  }
end

--- Find all notes in the vault that contain a wiki-link to the given target slug.
--- Matches [[target]] and [[target#anchor]] patterns.
---@param target string the slug to search for (no .md extension, relative to vault root)
---@param vault_root string the root directory of the vault
---@return table list of file paths that contain a link to the target
function M.find_backlinks(target, vault_root)
  assert(type(target) == "string", "target must be a string")
  assert(type(vault_root) == "string", "vault_root must be a string")
  assert(not target:match("%.md$"), "target should not include .md extension")

  local vault = require("dendrite.core.vault")
  local results = {}
  local pattern = "%[%[" .. target:gsub("%-", "%%-") .. "[%]#]"

  for _, path in ipairs(vault.list_notes(vault_root)) do
    local f = io.open(path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      if content:find(pattern) then
        table.insert(results, path)
      end
    end
  end
  return results
end

return M
