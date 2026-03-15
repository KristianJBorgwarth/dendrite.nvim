local M = {}

local defaults = {
  vault = "~/dendrite-vault",
  templates_dir = "~/dendrite-vault/.templates",
  scratch_notes = {
    dir = "~/dendrite-vault/scratches",
    template_name = "scratch",
  },
  daily_notes = {
    dir = "~/dendrite-vault/daily",
    filename_format = "%Y-%m-%d.md",
    template_name = "daily",
  },
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
