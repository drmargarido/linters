-- mod-version:1 -- lite-xl 1.16
local config = require "core.config"
local linter = require "plugins.linter"

config.zigcheck_args = {}

linter.add_language {
  file_patterns = {"%.zig$"},
  warning_pattern = "[^%s:]:(%d+):(%d+):[%s]?([^\n]+)",
  command = "zig ast-check $FILENAME $ARGS",
  deduplicate = true,
  args = config.zigcheck_args,
  expected_exitcodes = {0, 1}
}
