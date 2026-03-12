local M = {}

M.options = {
  -- The vault directory where all your notes and templates are stored
  -- Default: "~/dendrite-vault"
  vault = "~/dendrite-vault",

  -- The directory within the vault where your templates are stored
  -- Default: "~/dendrite-vault/.templates"
  templates_dir = "~/dendrite-vault/.templates",

  daily_notes = {
    -- The directory within the vault where your daily notes are stored
    -- Default: "~/dendrite-vault/daily"
    dir = "~/dendrite-vault/daily",

    -- The filename format for daily notes (using strftime format)
    -- Default: "%Y-%m-%d.md"
    filename_format = "%Y-%m-%d.md",
  },
}

return M
