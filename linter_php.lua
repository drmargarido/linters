local config = require "core.config"
local linter = require "plugins.linter"

config.phplint_args = {}

linter.add_language {
  file_patterns = {"%.php$"},
  warning_pattern = "[%a ]+:%s*(.*)%s+on%sline%s+(%d+)",
  warning_pattern_order = {line=2, col=nil, message=1},
  command = "php -l $ARGS $FILENAME 2>/dev/null",
  args = config.phplint_args
}
