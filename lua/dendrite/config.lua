local M = {}

local defaults = {
  vault = "~/dendrite-vault",

  templates_dir = "~/dendrite-vault/.templates",

  daily_notes = {
    dir = "~/dendrite-vault/daily",
    filename_format = "%Y-%m-%d.md",
  },
}

M.options = defaults

function M.setup(opts)
  opts = opts or {}

  M.options = vim.tbl_deep_extend(
    "force",
    defaults,
    opts)
end

return M
