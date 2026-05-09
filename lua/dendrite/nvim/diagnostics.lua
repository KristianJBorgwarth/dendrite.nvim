local M = {}

local ns = vim.api.nvim_create_namespace("dendrite_diagnostics")

function M.namespace()
	return ns
end

function M.publish(bufnr, daemon_diagnostics)
	local diagnostics = {}
	for _, d in pairs(daemon_diagnostics or {}) do
		local lnum = (d.line or 1) - 1
		local col = (d.col or 1) - 1
		local end_col = col + #(d.raw or "")

		table.insert(diagnostics, {
			lnum = lnum,
			col = col,
			end_col = end_col,
			severity = vim.diagnostic.severity.WARN,
			source = "dendrite",
			message = "Broken link:" .. (d.target or "?"),
		})
	end
	vim.diagnostic.set(ns, bufnr, diagnostics)
end

function M.clear(bufnr)
	vim.diagnostic.reset(ns, bufnr)
end

return M
