local M = {}

local proc = nil
local next_id = 1
local buffer = ""
local expected_length = nil
local pending = {}


function M.start(cmd)
  if proc then
    vim.notify("Dendrite daemon is already running", vim.log.levels.WARN)
    return
  end

  proc = vim.system(
    cmd,
    {
      stdin = true,
      stdout = function(_, data)
        if data then
          M._on_stdout(data)
        end
      end,
      stderr = function(_, data)
        if data then
          vim.notify(data, vim.log.levels.ERROR)
        end
      end,
    }
  )
end

function M.stop()
  if proc then
    proc:kill()
    proc = nil
  end
end

function M.request(method, params, callback)
  if not proc then
    vim.notify("Dendrite daemon is not running", vim.log.levels.ERROR)
    return
  end

  local id = next_id
  next_id = next_id + 1

  if callback then
    pending[id] = callback
  end

  local payload = vim.json.encode({
    jsonrpc = "2.0",
    id = id,
    method = method,
    params = params,
  })

  local msg = string.format("Content-Length: %d\r\n\r\n%s", #payload, payload)

  if not proc or proc:is_closing() then
    vim.notify("Dendrite daemon is not running", vim.log.levels.ERROR)
    return
  end

  proc:write(msg)

  return id
end

function M._on_stdout(chunk)
  buffer = buffer .. chunk

  while true do
    if not expected_length then
      local header_end = buffer:find("\r\n\r\n", 1, true)
      if not header_end then return end

      local header = buffer:sub(1, header_end)
      local len = header:match("Content%-Length:%s*(%d+)")
      if not len then
        vim.notify("Invalid response header", vim.log.levels.ERROR)
        return
      end

      expected_length = tonumber(len)
      buffer = buffer:sub(header_end + 4)
    end

    if #buffer < expected_length then return end

    local body = buffer:sub(1, expected_length)
    buffer = buffer:sub(expected_length + 1)
    expected_length = nil

    local ok, msg = pcall(vim.json.decode, body)
    if not ok then
      vim.notify("Failed to decode response", vim.log.levels.ERROR)
      return
    end

    M._handle_message(msg)
  end
end

function M._handle_message(msg)
  -- no notifications yet
  if not msg.id then
    vim.notify("Received message without id", vim.log.levels.WARN)
    return
  end

  local callback = pending[msg.id]
  if not callback then return nil end

  pending[msg.id] = nil
  callback(msg.result)
end

return M;
