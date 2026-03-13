local M = {}

local config = require("dendrite.config")

function M.setup(options)
  return config.setup(options)
end

return M
