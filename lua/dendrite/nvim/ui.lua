local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local make_entry = require("telescope.make_entry")

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

function M.search_frontmatter(keys, vault_root)
  local key_pattern = table.concat(keys, "|")

  pickers.new({}, {
    prompt_title = "Search Frontmatter",

    finder = finders.new_job(function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      return {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--glob", "*.md",
        "^(" .. key_pattern .. "):.*" .. prompt,
        vault_root
      }

    end, make_entry.gen_from_vimgrep({}), 100),

    previewer = conf.grep_previewer({}),
    sorter = conf.generic_sorter({}),
  }):find()
end

function M.input(prompt)
  local input = vim.fn.input(prompt)
  return input
end

return M
