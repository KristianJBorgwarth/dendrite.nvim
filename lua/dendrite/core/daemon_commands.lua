local M = {}
local config = require("dendrite.config")
local daemon = require("dendrite.core.daemon")
local diagnostics = require("dendrite.nvim.diagnostics")

local function init_params(vault)
	return {
		config = {
			vault_name = vault.vault_name,
			vault_path = vault.vault_path,
			templates_dir = vault.templates_dir,
			exclude_index_files = vault.exclude_index_files,
			override_default_ignores = vault.override_default_ignores,
			daily_notes = vault.daily_notes,
		},
	}
end

function M.init_vault(vault)
	daemon.request("vault/init", init_params(vault), function(response)
		vim.schedule(function()
			if response.error then
				vim.notify(
					"Daemon error: Failed to initialize vault '" .. vault.vault_name .. "': " .. response.error.message,
					vim.log.levels.ERROR
				)
			else
				vim.notify("Daemon Vault initialized successfully at: " .. vault.vault_path, vim.log.levels.INFO)
			end
		end)
	end)
end

function M.create(title, template_name, dir)
	daemon.request("note/create", {
		title = title,
		templateName = template_name,
		directory = dir,
		vault = config.active,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.cmd.edit(response.result)
			end
		end)
	end)
end

function M.completion_slug(query, callback)
	daemon.request("completion/slug", {
		query = query,
		vault = config.vault_name_for(vim.api.nvim_buf_get_name(0)),
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
				callback({})
			else
				callback(response.result)
			end
		end)
	end)
end

function M.save_note(path, callback)
	daemon.request("note/save", {
		path = path,
		vault = config.vault_name_for(path),
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
				return
			end
			if callback then
				callback(response.error == nil)
			end
		end)
	end)
end

function M.search_notes_by_tag(tag, callback)
	daemon.request("note/search_by_tag", {
		tag = tag,
		vault = config.active,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
				callback({})
			else
				callback(response.result or {})
			end
		end)
	end)
end

function M.goto_note(link)
	daemon.request("note/goto", {
		link = link,
		vault = config.vault_name_for(vim.api.nvim_buf_get_name(0)),
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
			else
				if response.result.type == "note" then
					vim.cmd.edit(response.result.target)
				elseif response.result.type == "url" then
					vim.notify("Opening URL: " .. response.result.target, vim.log.levels.INFO)
					vim.ui.open(response.result.target)
				else
					vim.notify("Daemon error: Unknown link type: " .. response.result.type, vim.log.levels.ERROR)
				end
			end
		end)
	end)
end

function M.completion_tag(query, callback)
	daemon.request("completion/tag", {
		query = query,
		vault = config.vault_name_for(vim.api.nvim_buf_get_name(0)),
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
				callback({})
			else
				callback(response.result)
			end
		end)
	end)
end

function M.get_backlinks(path, callback)
	daemon.request("note/backlinks", {
		path = path,
		vault = config.vault_name_for(path),
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
				callback({})
			else
				vim.notify("Found " .. #response.result .. " backlinks for this note", vim.log.levels.INFO)
				callback(response.result)
			end
		end)
	end)
end

function M.diagnostics_links(path, bufnr)
	daemon.request("diagnostics/links", {
		path = path,
		vault = config.vault_name_for(path),
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
			else
				diagnostics.publish(bufnr, response.result)
			end
		end)
	end)
end

function M.rebuild_index()
	daemon.request("vault/rebuild", { vault = config.active }, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: Failed to rebuild index: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.notify("Daemon index rebuilt successfully", vim.log.levels.INFO)
			end
		end)
	end)
end

return M
