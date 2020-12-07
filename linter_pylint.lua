local config = require "core.config"
local linter = require "plugins.linter"

config.pylint_args = {}

local pattern = function(text, filename)
  local line, col, warn, path, l, c, w
  for line_text in text:gmatch("[^\n]+") do
    -- Default pylint format: {path}:{line}:{column}: {msg_id}: {msg} ({symbol})
    path, l, c, w = line_text:match("([^:]):(%d+):(%d+):%s([%w]+:%s[^\n]*)")
    local has_filename = path and filename:match(linter.escape_to_pattern(path))
    if path then
      if warn then -- End of the last warning
        coroutine.yield(line, col, warn)
        warn = nil
      end
      -- Pylint reports columns as zero-based, linter.lua expects one-based
      if has_filename then line, col, warn = l, tonumber(c)+1, w end
    else
      if warn then warn = warn.."\n"..line_text end
    end
  end
  -- When we reach the end of the lines we didn't report the last warning
  if warn then coroutine.yield(line, col, warn) end
end

linter.add_language {
  file_patterns = {"%.py$"},
  warning_pattern = pattern,
  command = "pylint --score=n $ARGS $FILENAME", -- Disabled score output
  args = config.pylint_args
}
