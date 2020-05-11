local config = require "core.config"
local linter = require "plugins.linter"

config.golint_args = {}

linter.add_language {
  file_patterns = {"%.go$"},
  warning_pattern = "([^:]+):(%d+):(%d+):%s?([^\n]*)",
  command = "golint $ARGS ./...",
  args = config.golint_args
}

