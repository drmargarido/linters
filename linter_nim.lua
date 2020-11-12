local linter = require "plugins.linter"

local pattern
if PLATFORM == "Windows" then
  pattern = function(text, filename)
    local line, col, warn
    for line_text in text:gmatch("[^\n]+") do
      local has_path = line_text:match("[A-Z]:\\")
      local has_filename = line_text:match(linter.escape_to_pattern(filename))
      if has_path then
        if warn then coroutine.yield(line, col, warn) end
        if has_filename then
          line, col, warn = line_text:match("%((%d+), (%d+)%)([^\n]+)")
        else
          warn = nil -- New warning found but about another file
        end
      else
        if warn then warn = warn.."\n"..line_text end
      end
    end
    -- When we reach the end of the lines we didn't report the last warning
    if warn then coroutine.yield(line, col, warn) end
  end
else
  pattern = [[$FILENAME%((%d+), (%d+)%)([^\n]+[^/]*)]]
end

linter.add_language {
  file_patterns = {"%.nim$", "%.nims$"},
  warning_pattern = pattern,
  command = "nim --listfullpaths --stdout check $FILENAME",
  deduplicate = true
}
