local M = {}

local config = require("dendrite.config")
local actions = require("dendrite.nvim.actions")

function M.setup(options)
  config.setup(options)
end

function M.new_note(template_name, root_dir, fm_vars)
  actions.new_note(template_name, root_dir, fm_vars)
end

function M.daily_note()
  actions.daily_note()
end

return M
