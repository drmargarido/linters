local core = require "core"
local config = require "core.config"
local linter = require "plugins.linter"

config.ameba_args = {}

linter.add_language {
  file_patterns = {"%.cr$"},
  warning_pattern = "[^:]:(%d+):(%d+)\n[%s]?([^\n]+)",
  command = core.project_dir .. "/bin/ameba $FILENAME $ARGS --no-color",
  args = config.ameba_args
}
