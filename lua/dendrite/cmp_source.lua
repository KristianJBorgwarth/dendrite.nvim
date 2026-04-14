local M = {}

local daemon_commands = require("dendrite.core.daemon_commands")

function M.new()
	return setmetatable({}, { __index = M })
end

function M:get_trigger_characters()
	return { "[" }
end

function M:is_available()
	return vim.bo.filetype == "markdown"
end

function M:get_debug_name()
	return "dendrite"
end

function M:complete(params, callback)
	local line = params.context.cursor_before_line
	local query = line:match("%[%[([^%]]*)$")
	if not query then
		callback({ items = {}, isIncomplete = false })
		return
	end

	daemon_commands.completion_link(query, function(results)
		local items = {}
		for _, note in ipairs(results or {}) do
			table.insert(items, {
				label = note.display,
				insertText = note.slug,
				kind = require("cmp").lsp.CompletionItemKind.Reference,
				filterText = note.display .. " " .. note.slug,
			})
		end
		callback({ items = items, isIncomplete = true })
	end)
end

return M
