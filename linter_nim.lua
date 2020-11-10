local linter = require "plugins.linter"

local pattern
if PLATFORM == "Windows" then
  -- TODO: For now in windows we only display single line warnings
  pattern = [[$FILENAME%((%d+), (%d+)%)([^\n]+)]]
else
  pattern = [[$FILENAME%((%d+), (%d+)%)([^\n]+[^/]*)]]
end

linter.add_language {
  file_patterns = {"%.nim$", "%.nims$"},
  warning_pattern = pattern,
  command = "nim --listfullpaths --stdout check $FILENAME",
  deduplicate = true
}
