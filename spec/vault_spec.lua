---@diagnostic disable: undefined-field, param-type-mismatch, need-check-nil

local vault = require("lua.dendrite.core.vault")
local spec_utils = require("spec.spec_utils")

describe("vault.list_notes", function()
  local temp_dir = spec_utils.make_tmp_dir()

  before_each(function()
    -- create a small vault structure
    os.execute("mkdir -p " .. temp_dir .. "/axioms")
    os.execute("mkdir -p " .. temp_dir .. "/scratches")
    local function touch(path, content)
      local f = io.open(path, "w"); f:write(content or ""); f:close()
    end
    touch(temp_dir .. "/axioms/note1.md", "# Note 1")
    touch(temp_dir .. "/axioms/note2.md", "# Note 2")
    touch(temp_dir .. "/scratches/scratch1.md", "# Scratch")
    touch(temp_dir .. "/image.png", "not a note")
  end)

  it("returns all .md files recursively", function()
    local notes = vault.list_notes(temp_dir)
    assert.are.equal(3, #notes)
  end)

  it("does not include non-.md files", function()
    local notes = vault.list_notes(temp_dir)
    for _, path in ipairs(notes) do
      assert.is_true(path:match("%.md$") ~= nil)
    end
  end)

  it("returns empty table for empty vault", function()
    local empty_dir = spec_utils.make_tmp_dir()
    local notes = vault.list_notes(empty_dir)
    assert.are.equal(0, #notes)
  end)

  it("errors if vault_root is not a string", function()
    assert.has_error(function() vault.list_notes(123) end)
  end)
end)

describe("vault.list_directories", function()
  local temp_dir = spec_utils.make_tmp_dir()

  before_each(function()
    -- flat vault: two immediate subdirs, one nested subdir inside axioms
    os.execute("mkdir -p " .. temp_dir .. "/axioms/principles")
    os.execute("mkdir -p " .. temp_dir .. "/scratches")
    -- a file that should never appear in directory results
    local f = io.open(temp_dir .. "/axioms/note1.md", "w"); f:write(""); f:close()
  end)

  it("returns immediate subdirectories at depth 1", function()
    local dirs = vault.list_directories(temp_dir, 1)
    assert.are.equal(2, #dirs)
    local found = {}
    for _, d in ipairs(dirs) do found[d] = true end
    assert.is_true(found[temp_dir .. "/axioms"] ~= nil)
    assert.is_true(found[temp_dir .. "/scratches"] ~= nil)
  end)

  it("returns nested directories at depth 2", function()
    local dirs = vault.list_directories(temp_dir, 2)
    assert.are.equal(3, #dirs)
    local found = {}
    for _, d in ipairs(dirs) do found[d] = true end
    assert.is_true(found[temp_dir .. "/axioms/principles"] ~= nil)
  end)

  it("does not include files in results", function()
    local dirs = vault.list_directories(temp_dir, 2)
    for _, d in ipairs(dirs) do
      assert.is_false(d:match("%.md$") ~= nil)
    end
  end)

  it("returns empty table for vault with no subdirectories", function()
    local empty_dir = spec_utils.make_tmp_dir()
    local dirs = vault.list_directories(empty_dir, 1)
    assert.are.equal(0, #dirs)
  end)

  it("errors if vault_root is not a string", function()
    assert.has_error(function() vault.list_directories(123, 1) end)
  end)

  it("errors if depth is not a number", function()
    assert.has_error(function() vault.list_directories(temp_dir, "1") end)
  end)

  it("errors if depth is zero", function()
    assert.has_error(function() vault.list_directories(temp_dir, 0) end)
  end)

  it("errors if depth is negative", function()
    assert.has_error(function() vault.list_directories(temp_dir, -1) end)
  end)
end)
