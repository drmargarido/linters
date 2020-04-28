local linter = require "plugins.linter"

linter.add_language {
  file_patterns = {"%.go$"},
  warning_pattern = "[^:]:(%d+):(%d+):%s?([^\n]*)",
  command = "golint $FILENAME"
}

