local M = {}

local defaults = {
	vault_name = "dendrite-vault",
	vault_path = "~/dendrite-vault",
	templates_dir = "/.templates",
	scratch_notes = {
		dir = "/scratches",
		template_name = "scratch",
	},
	daily_notes = {
		dir = "/daily",
		filename_format = "%Y-%m-%d.md",
		template_name = "daily",
	},
}

M.options = vim.deepcopy(defaults)

function M.setup(opts)
	if opts ~= nil and type(opts) ~= "table" then
		error("dendrite.config.setup: expected 'opts' to be a table or nil, got " .. type(opts))
	end

	opts = opts or {}

	M.options = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)

	M.options.vault_path = vim.fn.expand(M.options.vault_path)
	M.options.templates_dir = vim.fn.expand(M.options.templates_dir)
	M.options.daily_notes.dir = vim.fn.expand(M.options.daily_notes.dir)
  M.options.scratch_notes.dir = vim.fn.expand(M.options.scratch_notes.dir)
end

return M
