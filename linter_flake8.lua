local linter = require "plugins.linter"

linter.add_language {
  file_patterns = {"%.py$"},
  warning_pattern = "[^:]:(%d+):(%d+):%s[%w]+%s([^\n]*)",
  command = "flake8 $FILENAME"
}
