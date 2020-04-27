local lint = require "plugins.lint"

lint.add_language {
file_patterns = {"%.py$"},
  warning_pattern = "(%d+):(%d+):[%s]?([^\n]*)",
  command = "pylint -s n --msg-template='{line}:{column}:{msg}' $FILENAME"
}
