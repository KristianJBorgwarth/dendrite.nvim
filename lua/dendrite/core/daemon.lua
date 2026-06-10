local M = {}

local state = {
	proc = nil,
	next_id = 1,
	buffer = "",
	pending = {},
}

local function handle_rpc_message(line)
	local ok, decoded = pcall(vim.json.decode, line)
	if not ok then
		vim.notify("Invalid JSON: " .. line, vim.log.levels.ERROR)
		return
	end

	local id = decoded.id
	if id and state.pending[id] then
		state.pending[id](decoded)
		state.pending[id] = nil
	end
end

local function on_stdout(_, data)
	if not data then
		return
	end

	state.buffer = state.buffer .. data

	while true do
		local line_end = state.buffer:find("\n", 1, true)
		if not line_end then
			break
		end

		local line = state.buffer:sub(1, line_end - 1)
		state.buffer = state.buffer:sub(line_end + 1)

		handle_rpc_message(line)
	end
end

local function on_stderr(_, data)
	if data then
		vim.schedule(function()
			vim.notify(data, vim.log.levels.ERROR)
		end)
	end
end

function M.start(cmd)
	if state.proc then
		vim.notify("Daemon already running", vim.log.levels.WARN)
		return
	end

	state.proc = vim.system({ cmd }, {
		stdin = true,
		stdout = on_stdout,
		stderr = on_stderr,
	})
end

function M.stop()
	if not state.proc then
		return
	end

	state.proc:kill(15)
	state.proc = nil
	state.pending = {}
	state.buffer = ""
end

function M.request(method, params, callback)
	if not state.proc then
		error("daemon not started")
	end

	local id = state.next_id
	state.next_id = id + 1

	state.pending[id] = callback

	local payload = vim.json.encode({
		jsonrpc = "2.0",
		id = id,
		method = method,
		params = params or {},
	})

	state.proc:write(payload .. "\n")
end

return M
