local linter = require "plugins.linter"

linter.add_language {
  file_patterns = {"%.nim$", "%.nims$"},
  warning_pattern = [[$FILENAME%((%d+), (%d+)%)([^\n]+[^\//]*)]],
  command = "nim check $FILENAME 2>&1",
  deduplicate = true
}
