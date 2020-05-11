-- this is for standardjs linting

local config = require "core.config"
local linter = require "plugins.linter"

-- add auto-fixing by adding '--fix' to your options
config.standard_args = {}

linter.add_language {
  file_patterns = {"%.js$"},
  warning_pattern = "[^:]:(%d+):(%d+): ([^\n]+)",
  command = "standard --verbose $ARGS $FILENAME",
  args = config.standard_args
}
