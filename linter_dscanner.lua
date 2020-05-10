local config = require "core.config"
local linter = require "plugins.linter"

config.dscanner_args = {"-S"}

linter.add_language {
  file_patterns = {"%.d$"},
  warning_pattern = "[^:]%((%d+):(%d+)%)[%s]?([^\n]+)",
  command = "dscanner $FILENAME $ARGS",
  args = config.dscanner_args
}
