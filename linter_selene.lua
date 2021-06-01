local config = require "core.config"
local linter = require "plugins.linter"

config.selene_args = {}

linter.add_language {
  file_patterns = {"%.lua$", "%.luau$"},
  warning_pattern = ".-:(%d+):(%d+): .-:([^\n]+)",
  command = "selene $FILENAME --display-style quiet $ARGS",
  args = config.selene_args,
  expected_exitcodes = {0}
}
