local M = {}

--- List all markdown notes in a vault recursively.
---@param vault_root string the root directory of the vault
---@return table a list of absolute file paths to .md files
function M.list_notes(vault_root)
  assert(type(vault_root) == "string", "vault_root must be a string")

  local results = {}
  local p = io.popen('find "' .. vault_root .. '" -type f -name "*.md"')
  if not p then
    error("Could not list notes in vault: " .. vault_root)
  end

  for path in p:lines() do
    table.insert(results, path)
  end
  p:close()

  return results
end

--- List all directories in a vault recursively by a specified depth.
---@param vault_path string the root directory of the vault
---@param depth number the maximum depth to search for directories (1 for immediate subdirectories, 2 for subdirectories of subdirectories, etc.)
---@return table a list of absolute directory paths
function M.list_directories(vault_path, depth)
  assert(type(vault_path) == "string", "vault_root must be a string")
  assert(type(depth) == "number" and depth > 0, "depth must be a positive number")

  local results = {}
  local find_command = 'find "' .. vault_path .. '" -type d -mindepth 1 -maxdepth ' .. depth
  local p = io.popen(find_command)

  if not p then
    error("Could not list directories in vault: " .. vault_path)
  end

  for path in p:lines() do
    table.insert(results, path)
  end
  p:close()
  return results
end


return M
