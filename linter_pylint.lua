local config = require "core.config"
local linter = require "plugins.linter"

config.pylint_args = {}

linter.add_language {
  file_patterns = {"%.py$"},
  warning_pattern = "[^%d]+(%d+)[^%d]+(%d+):%s([^\n]*)", -- Default pylint format
  column_starts_at_zero = true,
  command = "pylint --score=n $ARGS $FILENAME", -- Disabled score output
  args = config.pylint_args
}
