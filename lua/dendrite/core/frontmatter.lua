local M = {}

--- Parse a YAML array string like ["a", "b"] or [a, b] into a Lua table.
---@param s string the raw array string including brackets
---@return table
local function parse_array(s)
  local items = {}
  local inner = s:match("^%[(.*)%]$")
  if not inner then return items end
  for item in inner:gmatch('[^,]+') do
    item = item:match('^%s*"?(.-)"?%s*$')
    if item ~= "" then
      table.insert(items, item)
    end
  end
  return items
end

--- Parse the YAML frontmatter block from note content.
--- Reads title, tags, created, and updated keys if present.
---@param content string the full note content
---@return table|nil data parsed key-value table, or nil if no frontmatter found
---@return string body the note content after the frontmatter block
function M.parse(content)
  assert(type(content) == "string", "content must be a string")

  local fm, body = content:match("^%-%-%-\n(.-)\n%-%-%-\n?(.*)")
  if not fm then
    return nil, content
  end

  local data = {}
  for line in fm:gmatch("[^\n]+") do
    local key, value = line:match("^([%w_]+):%s*(.+)$")
    if key and value then
      if value:match("^%[") then
        data[key] = parse_array(value)
      else
        data[key] = value:match('^"?(.-)"?$')
      end
    end
  end

  return data, body
end

--- Serialize a data table into a YAML frontmatter string.
--- Supports string values and array values (tables).
---@param data table key-value pairs to serialize
---@return string the frontmatter block including --- delimiters
function M.serialize(data)
  assert(type(data) == "table", "data must be a table")

  local lines = { "---" }
  for key, value in pairs(data) do
    if type(value) == "table" then
      local quoted = {}
      for _, v in ipairs(value) do
        table.insert(quoted, '"' .. tostring(v) .. '"')
      end
      table.insert(lines, key .. ': [' .. table.concat(quoted, ", ") .. ']')
    else
      table.insert(lines, key .. ': "' .. tostring(value) .. '"')
    end
  end
  table.insert(lines, "---")

  return table.concat(lines, "\n")
end

return M
