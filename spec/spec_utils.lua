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

function M.write_tmp_file(name, content)
  local temp_dir = M.make_tmp_dir()
  local file_path = temp_dir .. "/" .. name
  local file = io.open(file_path, "w")
  if not file then
    error("Could not create temporary file: " .. file_path)
  end
  file:write(content)
  file:close()
  return file_path
end

return M
