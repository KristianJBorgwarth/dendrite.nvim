local M = {}

local config = require("dendrite.config")

function M.setup(options)
  config.setup(options)
end

return M
