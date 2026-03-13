---@diagnostic disable: undefined-field, param-type-mismatch, need-check-nil
local search = require("dendrite.core.search")
local spec_utils = require("spec.spec_utils")

local function write_note(path, content)
  local f = io.open(path, "w")
  f:write(content)
  f:close()
end

describe("search.search_notes", function()
  local temp_dir = spec_utils.make_tmp_dir()

  before_each(function()
    write_note(temp_dir .. "/alpha.md", "The quick brown fox")
    write_note(temp_dir .. "/beta.md", "A lazy dog sat here")
  end)

  it("returns files matching query", function()
    local results = search.search_notes("quick", temp_dir)
    assert.are.equal(1, #results)
    assert.is_true(results[1]:find("alpha") ~= nil)
  end)

  it("is case-insensitive", function()
    local results = search.search_notes("LAZY", temp_dir)
    assert.are.equal(1, #results)
  end)

  it("returns empty table when no match", function()
    local results = search.search_notes("elephant", temp_dir)
    assert.are.equal(0, #results)
  end)

  it("errors if query is not a string", function()
    assert.has_error(function() search.search_notes(123, temp_dir) end)
  end)
end)

describe("search.search_by_tag", function()
  local temp_dir = spec_utils.make_tmp_dir()

  before_each(function()
    write_note(temp_dir .. "/tagged.md", '---\ntitle: "Tagged"\ntags: ["lua", "notes"]\n---\nContent')
    write_note(temp_dir .. "/other-tag.md", '---\ntitle: "Other"\ntags: ["vim"]\n---\nContent')
    write_note(temp_dir .. "/no-fm.md", 'No frontmatter here')
  end)

  it("returns notes with matching tag", function()
    local results = search.search_by_tag("lua", temp_dir)
    assert.are.equal(1, #results)
    assert.is_true(results[1]:find("tagged") ~= nil)
  end)

  it("does not return notes with different tags", function()
    local results = search.search_by_tag("lua", temp_dir)
    for _, p in ipairs(results) do
      assert.is_false(p:find("other%-tag") ~= nil)
    end
  end)

  it("returns empty table when tag not found", function()
    local results = search.search_by_tag("nonexistent", temp_dir)
    assert.are.equal(0, #results)
  end)

  it("skips notes without frontmatter", function()
    local results = search.search_by_tag("lua", temp_dir)
    for _, p in ipairs(results) do
      assert.is_false(p:find("no%-fm") ~= nil)
    end
  end)

  it("errors if tag is not a string", function()
    assert.has_error(function() search.search_by_tag(99, temp_dir) end)
  end)
end)

describe("search.search_by_date", function()
  local temp_dir = spec_utils.make_tmp_dir()

  before_each(function()
    write_note(temp_dir .. "/jan.md", '---\ncreated: 2024-01-15T10:00:00Z\n---\n')
    write_note(temp_dir .. "/feb.md", '---\ncreated: 2024-02-20T10:00:00Z\n---\n')
    write_note(temp_dir .. "/no-date.md", '---\ntitle: "No date"\n---\n')
  end)

  it("matches notes by full date prefix", function()
    local results = search.search_by_date("2024-01-15", temp_dir)
    assert.are.equal(1, #results)
    assert.is_true(results[1]:find("jan") ~= nil)
  end)

  it("matches notes by year-month prefix", function()
    local results = search.search_by_date("2024-01", temp_dir)
    assert.are.equal(1, #results)
  end)

  it("matches notes by year prefix", function()
    local results = search.search_by_date("2024", temp_dir)
    assert.are.equal(2, #results)
  end)

  it("returns empty when no notes match", function()
    local results = search.search_by_date("2025", temp_dir)
    assert.are.equal(0, #results)
  end)

  it("skips notes without created field", function()
    local results = search.search_by_date("2024", temp_dir)
    for _, p in ipairs(results) do
      assert.is_false(p:find("no%-date") ~= nil)
    end
  end)

  it("errors if date is not a string", function()
    assert.has_error(function() search.search_by_date(2024, temp_dir) end)
  end)
end)
