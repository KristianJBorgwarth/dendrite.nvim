local M = {}
local daemon = require("dendrite.core.daemon")

function M.init_vault(name, path, templates)
	daemon.request("vault/init", {
		vaultName = name,
		vaultPath = path,
		templateDirectory = templates,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: Failed to initialize vault: " .. response.error.message, vim.log.levels.ERROR)
			else
				vim.notify("Daemon Vault initialized successfully at: " .. path, vim.log.levels.INFO)
			end
		end)
	end)
end

function M.create(title, template_name, dir)
	daemon.request("note/create", {
		title = title,
		templateName = template_name,
		directory = dir,
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

function M.completion_link(query, callback)
	daemon.request("completion/link", {
		query = query,
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

function M.save_note(path)
	daemon.request("note/save", {
		path = path,
	}, function(response)
		vim.schedule(function()
			if response.error then
				vim.notify("Daemon error: " .. response.error.message, vim.log.levels.ERROR)
			end
		end)
	end)
end

function M.goto_note(link)
	daemon.request("note/goto", {
		link = link,
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

function M.rebuild_index()
	daemon.request("vault/rebuild", {}, function(response)
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
