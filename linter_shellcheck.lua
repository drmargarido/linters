local config = require "core.config"
local linter = require "plugins.linter"

config.shellcheck_args = {}

linter.add_language {
  file_patterns = {"%.sh$"},
  warning_pattern = "[^:]:(%d+):(%d+):%s?([^\n]*)",
  command = "shellcheck -f gcc $ARGS $FILENAME 2>&1",
  args = config.shellcheck_args
}
