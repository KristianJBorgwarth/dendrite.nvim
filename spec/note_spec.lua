---@diagnostic disable: undefined-field, param-type-mismatch, need-check-nil
local note = require("lua.dendrite.core.note")
local spec_utils = require("spec.spec_utils")

describe("slugify", function()
  it("lowercases and replaces spaces", function()
    assert.are.equal("my-note", note._slugify("My Note"))
  end)

  it("removes special characters", function()
    assert.are.equal("hello-world", note._slugify("Hello, World!"))
  end)

  it("trims leading and trailing dashes", function()
    assert.are.equal("note", note._slugify("---Note---"))
  end)
end)

describe("render_template", function()
  it("replaces placeholders", function()
    -- arrange
    local template = "Hello {{name}}, the date is {{local_time}}"

    -- act
    local result = note._render_template(template, { name = "Master", local_time = "2024-06-01" })

    -- assert
    assert.are.equal("Hello Master, the date is 2024-06-01", result)
  end)

  it("allows empty string as a variable value", function()
    local result = note._render_template("Hello {{name}}", { name = "" })
    assert.are.equal("Hello ", result)
  end)
end)

describe("validate_note_params", function()
  it("validates required fields", function()
    -- arrange & act & assert
    assert.has_no.errors(function()
      note._validate_note_params("My Note", "Content", "path.md", {})
    end)
  end)

  it("errors if title missing", function()
    -- arrange & act & assert
    assert.has_error(function() note._validate_note_params(1, "Content", "path.md", {}) end)
  end)

  it("errors if content missing", function()
    -- arrange & act & assert
    assert.has_error(function()
      note._validate_note_params("Title", 3, "path.md", {})
    end)
  end)
end)

describe("create_note", function()
  local temp_dir = spec_utils.make_tmp_dir()

  it("creates a note with empty vars", function()
    -- arrange
    local expected_path = temp_dir .. "/my-note.md"
    local file_path = spec_utils.write_tmp_file("test", "This is the content of the note.")

    -- act
    local actual_path, created = note.create_note("My Note", file_path, temp_dir, {})

    -- assert
    assert.is_not_nil(actual_path)
    assert.is_true(expected_path == actual_path)
    assert.is_true(created)
    local content = spec_utils.read_file(actual_path)
    assert.are.equal("This is the content of the note.", content)
  end)

  it("creates a note with vars", function()
    -- arrange
    local expected_path = temp_dir .. "/my-var-note.md"

    local file_path = spec_utils.write_tmp_file("template", "Hello {{name}}, today is {{date}}!")

    -- act
    local actual_path, created = note.create_note("My Var??? Note", file_path, temp_dir, { name = "World", date = os.date("%Y-%m-%d") })

    -- assert
    assert.is_not_nil(actual_path)
    assert.is_true(expected_path == actual_path)
    assert.is_true(created)
    local content = spec_utils.read_file(actual_path)
    assert.are.equal("Hello World, today is " .. os.date("%Y-%m-%d") .. "!", content)
  end)

  it("does not overwrite existing note", function()
    -- arrange
    local path = temp_dir .. "/existing-note.md"
    local file = io.open(path, "w")
    file:write("Existing content")
    file:close()

    local file_path = spec_utils.write_tmp_file("template", "New content")

    -- act
    local actual_path, created = note.create_note("Existing Note", file_path, temp_dir, {})

    -- assert
    assert.is_not_nil(actual_path)
    assert.is_true(path == actual_path)
    assert.is_false(created)
    local content = spec_utils.read_file(actual_path)
    assert.are.equal("Existing content", content)
  end)

  it("errors with invalid params", function()
    -- arrange & act & assert
    assert.has_error(function()
      note.create_note(1, 2, 3, 4)
    end)
  end)

  it("errors if template variable missing", function()
    -- arrange 
    local invalid_temps = "shite"

    -- act & assert
    assert.has_error(function()
      note.create_note("Title", "Content with {{var}}", temp_dir, invalid_temps)
    end)
  end)
end)
