-- mod-version:3
-- linter for eslint

local config = require "core.config"
local linter = require "plugins.linter"

-- add --fix to your args for auto-fixing.
config.eslint_args = {}

linter.add_language {
  file_patterns = {"%.js$"},
  warning_pattern = "[^:]:(%d+):(%d+): ([^\n]+)",
  command = "eslint --format unix $ARGS $FILENAME",
  args = config.eslint_args,
  expected_exitcodes = {0, 1}
}
