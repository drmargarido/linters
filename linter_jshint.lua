-- mod-version:3
-- this is for the jshint linter

local config = require "core.config"
local linter = require "plugins.linter"

-- if you want to specify any CLI arguments
config.jshint_args = {}

linter.add_language {
  file_patterns = {"%.js$"},
  warning_pattern = "[^:]: line (%d+), col (%d+), ([^\n]+)",
  command = "jshint $ARGS $FILENAME",
  args = config.jshint_args,
  expected_exitcodes = {0, 1, 2}
}
