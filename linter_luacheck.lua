local lint = require "plugins.lint"

lint.add_language {
  file_patterns = {"%.lua$"},
  warning_pattern = "[^:]:(%d+):(%d+):[%s]?([^\n]+)",
  command = "luacheck --formatter=plain $FILENAME"
}
