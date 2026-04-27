local M = {}
local daemon_commands = require("dendrite.core.daemon_commands")

function M.new()
  return setmetatable({}, { __index = M })
end

function M:get_trigger_characters()
  return { "[", "\"" }
end

function M:is_available()
  return vim.bo.filetype == "markdown"
end

function M:get_debug_name()
  return "dendrite"
end

function M:complete(params, callback)
  local line = params.context.cursor_before_line

  local slug_query = line:match("%[%[([^%]]*)$")
  if slug_query then
    daemon_commands.completion_slug(slug_query, function(results)
      local items = {}
      for _, note_slug in ipairs(results or {}) do
        table.insert(items, {
          label = note_slug,
          insertText = note_slug,
          kind = require("cmp").lsp.CompletionItemKind.Reference,
          filterText = note_slug,
        })
      end
      callback({ items = items, isIncomplete = true })
    end)
    return
  end

  local tag_query = line:match("^tags:%s*%[.*\"([^\"]+)$")
  if tag_query then
    daemon_commands.completion_tag(tag_query, function(results)
      local items = {}
      for _, tag in ipairs(results or {}) do
        table.insert(items, {
          label = tag,
          insertText = tag,
          kind = require("cmp").lsp.CompletionItemKind.Keyword,
          filterText = tag,
        })
      end
      callback({ items = items, isIncomplete = true })
    end)
    return
  end

  callback({ items = {}, isIncomplete = false })
end

return M
