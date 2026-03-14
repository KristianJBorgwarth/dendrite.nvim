local M = {}

local defaults = {
  vault = "~/dendrite-vault",
  templates_dir = "~/dendrite-vault/.templates",
  daily_notes = {
    dir = "~/dendrite-vault/daily",
    filename_format = "%Y-%m-%d.md",
  },
  use_default_frontmatter = true,
}

M.options = vim.deepcopy(defaults)

function M.setup(opts)
  if opts ~= nil and type(opts) ~= "table" then
    error(
      "dendrite.config.setup: expected 'opts' to be a table or nil, got "
      .. type(opts)
    )
  end

  opts = opts or {}

  M.options = vim.tbl_deep_extend(
    "force",
    vim.deepcopy(defaults),
    opts)

  M.options.vault = vim.fn.expand(M.options.vault)
  M.options.templates_dir = vim.fn.expand(M.options.templates_dir)
  M.options.daily_notes.dir = vim.fn.expand(M.options.daily_notes.dir)

end

return M
