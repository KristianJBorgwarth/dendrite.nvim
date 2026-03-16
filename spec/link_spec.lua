---@diagnostic disable: undefined-field, param-type-mismatch, need-check-nil
local link = require("lua.dendrite.core.link")
local spec_utils = require("spec.spec_utils")

describe("resolve_link", function()

  local temp_dir = spec_utils.make_tmp_dir()

  it("resolves a link without anchor", function()
    -- arrange
    local path = temp_dir .. "/note.md"
    local file = io.open(path, "w")
    file:write("content")
    file:close()

    -- act
    local result = link.resolve_link("note", temp_dir)

    -- assert
    assert.is_not_nil(result)
    assert.are.equal(path, result.path)
    assert.is_nil(result.anchor)
    assert.is_true(result.exists)
  end)

  it("resolves a link with anchor", function()
    -- arrange
    local path = temp_dir .. "/note-with-anchor.md"
    local file = io.open(path, "w")
    file:write("content")
    file:close()

    -- act
    local result = link.resolve_link("note-with-anchor#section-2", temp_dir)

    -- assert
    assert.are.equal(path, result.path)
    assert.are.equal("section-2", result.anchor)
    assert.is_true(result.exists)
  end)

  it("returns exists=false when file does not exist", function()
    -- act
    local result = link.resolve_link("nonexistent", temp_dir)

    -- assert
    assert.are.equal(temp_dir .. "/nonexistent.md", result.path)
    assert.is_false(result.exists)
    assert.is_nil(result.anchor)
  end)

  it("errors if link contains .md extension", function()
    -- act & assert
    assert.has_error(function()
      link.resolve_link("note.md", temp_dir)
    end)
  end)

  it("errors if anchor contains invalid characters", function()
    -- act & assert
    assert.has_error(function()
      link.resolve_link("note#Section 2", temp_dir)
    end)
  end)

  it("errors if anchor contains uppercase letters", function()
    -- act & assert
    assert.has_error(function()
      link.resolve_link("note#Section-2", temp_dir)
    end)
  end)

  it("errors if vault_root is not a string", function()
    -- act & assert
    assert.has_error(function()
      link.resolve_link("note", 123)
    end)
  end)

  it("errors if link is not a string", function()
    -- act & assert
    assert.has_error(function()
      link.resolve_link(123, temp_dir)
    end)
  end)

end)

describe("link.find_backlinks", function()
  local temp_dir = spec_utils.make_tmp_dir()

  before_each(function()
    local function write(path, content)
      local f = io.open(path, "w"); f:write(content); f:close()
    end
    write(temp_dir .. "/source-a.md", "See also [[target-note]] for details")
    write(temp_dir .. "/source-b.md", "Reference [[target-note#section-1]] here")
    write(temp_dir .. "/source-c.md", "No links here at all")
    write(temp_dir .. "/target-note.md", "This is the target")
  end)

  it("finds notes that link to the target", function()
    local results = link.find_backlinks("target-note", temp_dir)
    assert.are.equal(2, #results)
  end)

  it("matches links with anchors", function()
    local results = link.find_backlinks("target-note", temp_dir)
    local found_b = false
    for _, p in ipairs(results) do
      if p:find("source%-b") then found_b = true end
    end
    assert.is_true(found_b)
  end)

  it("does not include the target file itself", function()
    local results = link.find_backlinks("target-note", temp_dir)
    for _, p in ipairs(results) do
      assert.is_false(p:find("target%-note") ~= nil and not p:find("source"))
    end
  end)

  it("returns empty table when no backlinks exist", function()
    local results = link.find_backlinks("orphan-note", temp_dir)
    assert.are.equal(0, #results)
  end)

  it("errors if target includes .md extension", function()
    assert.has_error(function()
      link.find_backlinks("target-note.md", temp_dir)
    end)
  end)

  it("errors if target is not a string", function()
    assert.has_error(function()
      link.find_backlinks(123, temp_dir)
    end)
  end)
end)
