local M = {}

---@param vault_path string the root directory of the vault
---@param depth number the maximum depth to search for directories (1 for immediate subdirectories, 2 for subdirectories of subdirectories, etc.)
---@return table a list of absolute directory paths
function M.list_directories(vault_path, depth)
  assert(type(vault_path) == "string", "vault_root must be a string")
  assert(type(depth) == "number" and depth > 0, "depth must be a positive number")

  local results = {}
  local find_command = 'find "' .. vault_path .. '" -mindepth 1 -maxdepth ' .. depth .. ' -type d 2>/dev/null'
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

function M.read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil, "Could not read file at: " .. path
  end
  local content = file:read("*a")
  file:close()
  return content
end

return M
