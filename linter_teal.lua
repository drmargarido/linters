local config = require "core.config"
local linter = require "plugins.linter"

config.tlcheck_args = {}

linter.add_language {
  file_patterns = {"%.tl$"},
  warning_pattern = "[^:]:(%d+):(%d+):[%s]?([^\n]+)",
  command = "tl check $FILENAME $ARGS",
  args = config.tlcheck_args,
  expected_exitcodes = {0}
}
