local linter = require "plugins.linter"
local PATHSEP = package.config:sub(1, 1)

local pattern = function(text, filename)
  local line, col, warn, path, l, c, w
  for line_text in text:gmatch("[^\n]+") do
    path, l, c, w = line_text:match("([^:]+):(%d+):(%d+):[%s]?([^\n]+)")
    local has_filename = path and filename:match(linter.escape_to_pattern(path))
    if path then
      if warn then -- End of the last warning
        coroutine.yield(line, col, warn)
        warn = nil
      end
      if has_filename then line, col, warn = l, c, w end
    else
      if warn then warn = warn.."\n"..line_text end
    end
  end
  -- When we reach the end of the lines we didn't report the last warning
  if warn then coroutine.yield(line, col, warn) end
end


linter.add_language {
  file_patterns = {"%.go$"},
  warning_pattern = pattern,
  command = "go vet -source $FILENAME"..PATHSEP..".."..PATHSEP.." 2>&1",
  args = {}
}
