local frontmatter = require("dendrite.core.frontmatter")

describe("frontmatter.parse", function()
  it("returns nil and full content when no frontmatter present", function()
    local data, body = frontmatter.parse("# Just a note\nNo frontmatter here.")
    assert.is_nil(data)
    assert.are.equal("# Just a note\nNo frontmatter here.", body)
  end)

  it("parses title", function()
    local content = '---\ntitle: "My Note"\n---\nBody text'
    local data, body = frontmatter.parse(content)
    assert.is_not_nil(data)
    assert.are.equal("My Note", data.title)
    assert.are.equal("Body text", body)
  end)

  it("parses tags as a table", function()
    local content = '---\ntags: ["lua", "notes"]\n---\n'
    local data = frontmatter.parse(content)
    assert.is_not_nil(data)
    assert.are.equal(2, #data.tags)
    assert.are.equal("lua", data.tags[1])
    assert.are.equal("notes", data.tags[2])
  end)

  it("parses created and updated timestamps", function()
    local content = '---\ncreated: 2024-01-01T12:00:00Z\nupdated: 2024-01-02T12:00:00Z\n---\n'
    local data = frontmatter.parse(content)
    assert.is_not_nil(data)
    assert.are.equal("2024-01-01T12:00:00Z", data.created)
    assert.are.equal("2024-01-02T12:00:00Z", data.updated)
  end)

  it("parses all keys together", function()
    local content = '---\ntitle: "Full Note"\ntags: ["a", "b"]\ncreated: 2024-01-01T00:00:00Z\nupdated: 2024-06-01T00:00:00Z\n---\nContent'
    local data, body = frontmatter.parse(content)
    assert.is_not_nil(data)
    assert.are.equal("Full Note", data.title)
    assert.are.equal(2, #data.tags)
    assert.are.equal("2024-01-01T00:00:00Z", data.created)
    assert.are.equal("Content", body)
  end)

  it("errors if content is not a string", function()
    assert.has_error(function() frontmatter.parse(123) end)
  end)
end)

describe("frontmatter.serialize", function()
  it("wraps output in --- delimiters", function()
    local result = frontmatter.serialize({ title = "Hello" })
    assert.is_true(result:sub(1, 3) == "---")
    assert.is_true(result:sub(-3) == "---")
  end)

  it("serializes string values", function()
    local result = frontmatter.serialize({ title = "My Note" })
    assert.is_not_nil(result:find('title: "My Note"'))
  end)

  it("serializes array values", function()
    local result = frontmatter.serialize({ tags = { "lua", "notes" } })
    assert.is_not_nil(result:find('tags: %['))
    assert.is_not_nil(result:find('"lua"'))
    assert.is_not_nil(result:find('"notes"'))
  end)

  it("errors if data is not a table", function()
    assert.has_error(function() frontmatter.serialize("not a table") end)
  end)

  it("round-trips through parse", function()
    local original = { title = "Round Trip", tags = { "x", "y" }, created = "2024-01-01T00:00:00Z" }
    local serialized = frontmatter.serialize(original)
    local parsed = frontmatter.parse(serialized .. "\n")
    assert.are.equal("Round Trip", parsed.title)
    assert.are.equal("x", parsed.tags[1])
    assert.are.equal("2024-01-01T00:00:00Z", parsed.created)
  end)
end)
