local M = {}

function M.read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil, "Could not open file: " .. path
  end
  local content = file:read("*a")
  file:close()
  return content
end

function M.make_tmp_dir()
  local temp_dir = os.tmpname()
  os.remove(temp_dir)
  os.execute("mkdir -p " .. temp_dir)
  return temp_dir
end

return M
