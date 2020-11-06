local config = require "core.config"
local linter = require "plugins.linter"

config.nimcheck_args = {}


local check = [[nim check $ARGS $FILENAME 2>&1]]
local grep = [[grep -Pzo '\n$FILENAME\((\d+), (\d+)\)(.|\n)*?(?=\n/)']]
linter.add_language {
  file_patterns = {"%.nim$", "%.nims$"},
  warning_pattern = "%((%d+), (%d+)%)(.-)\n/",
  command = [[bash -c "cat <(cat <(]] .. check .. [[) <(echo /) | ]] .. grep .. [[) <(echo -e '\n/')"]],
  args = config.nimcheck_args
}
