local config = require "core.config"
local linter = require "plugins.linter"

config.luacheck_args = {}

linter.add_language {
  file_patterns = {"%.lua$"},
  warning_pattern = "[^:]:(%d+):(%d+):[%s]?([^\n]+)",
  command = "luacheck $FILENAME --formatter=plain $ARGS",
  args = config.luacheck_args,
  expected_exitcodes = {0, 1}
}
