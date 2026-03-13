local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

function M.selector(dirs, on_select)
  pickers.new({}, {
    prompt_title = "Select directory",
    finder = finders.new_table({ results = dirs }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()[1]
        on_select(selection)
      end)
      return true
    end,
  }):find()
end

function M.input(prompt)
  local input = vim.fn.input(prompt)
  return input
  end

return M
