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

local global_keys = { vaults = true, default_vault = true, daemon_path = true }

M.options = {}
M.vaults = {}
M.active = nil

local function normalize(vault)
	vault.vault_path = vim.fn.expand(vault.vault_path):gsub("(.)/+$", "%1")
	vault.templates_dir = vim.fn.expand(vault.templates_dir)
	vault.daily_notes.dir = vim.fn.expand(vault.daily_notes.dir)
	vault.scratch_notes.dir = vim.fn.expand(vault.scratch_notes.dir)
	return vault
end

local function sorted_names()
	local names = vim.tbl_keys(M.vaults)
	table.sort(names)
	return names
end

local function build_vaults(opts)
	local shared = {}
	for key, value in pairs(opts) do
		if not global_keys[key] then
			shared[key] = value
		end
	end

	local merged = vim.tbl_deep_extend("force", vim.deepcopy(defaults), shared)
	local vaults = {}

	if opts.vaults == nil then
		vaults[merged.vault_name] = normalize(merged)
		return vaults
	end

	merged.vault_name = nil
	merged.vault_path = nil

	for name, entry in pairs(opts.vaults) do
		if type(entry) ~= "table" then
			error("dendrite.config.setup: vault '" .. name .. "' must be a table")
		end
		local vault = vim.tbl_deep_extend("force", vim.deepcopy(merged), entry)
		vault.vault_name = name
		vault.vault_path = entry.path or ""
		vault.path = nil
		vaults[name] = normalize(vault)
	end

	if next(vaults) == nil then
		error("dendrite.config.setup: 'vaults' must contain at least one vault")
	end

	return vaults
end

function M.setup(opts)
	if opts ~= nil and type(opts) ~= "table" then
		error("dendrite.config.setup: expected 'opts' to be a table or nil, got " .. type(opts))
	end

	opts = opts or {}

	M.options = { daemon_path = opts.daemon_path }
	M.vaults = build_vaults(opts)

	local default = opts.default_vault
	M.default_vault = default
	if default ~= nil and M.vaults[default] == nil then
		error("dendrite.config.setup: default_vault '" .. default .. "' is not in 'vaults'")
	end
	M.active = default or sorted_names()[1]
end

function M.names()
	return sorted_names()
end

function M.vault()
	return M.vaults[M.active]
end

function M.new_vault(name, path)
	local vault = vim.deepcopy(M.vault())
	vault.vault_name = name
	vault.vault_path = path
	return normalize(vault)
end

function M.adopt(name, path)
	if M.vaults[name] == nil then
		M.vaults[name] = M.new_vault(name, path)
	end
end

function M.set_path(name, path)
	local vault = M.vaults[name]
	if vault then
		vault.vault_path = path:gsub("(.)/+$", "%1")
	end
end

function M.register(vault)
	M.vaults[vault.vault_name] = vault
end

function M.set_active(name)
	if M.vaults[name] == nil then
		error("dendrite: unknown vault '" .. name .. "'")
	end
	M.active = name
end

function M.vault_for_path(path)
	local best
	for _, vault in pairs(M.vaults) do
		local root = vault.vault_path
		if vim.startswith(path, root .. "/") and (not best or #root > #best.vault_path) then
			best = vault
		end
	end
	return best
end

function M.vault_name_for(path)
	local vault = path and M.vault_for_path(path)
	return vault and vault.vault_name or M.active
end

return M
