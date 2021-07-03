# linters
Linters for https://github.com/rxi/lite

## Available linters

* linter\_ameba - Uses ameba for crystal files
* linter\_dscanner - Uses dscanner for d files
* linter\_eslint - Uses eslint for javascript files
* linter\_flake8 - Uses flake8 for python files
* linter\_gocompiler - Uses the go vet command to display compilation errors in golang files
* linter\_golint - Uses golint for golang files
* linter\_jshint - Uses jshint linter for javascript files
* linter\_luacheck - Uses luacheck for lua files
* linter\_teal - Uses tl check for teal files
* linter\_nim - Uses nim check for nim files
* linter\_php - Uses built-in php binary -l flag for php files
* linter\_pylint - Uses pylint for python files
* linter\_selene - Uses selene for lua files
* linter\_shellcheck - Uses shellcheck linter for shell script files
* linter\_standard - Uses standard linter for javascript files
* linter_zig - Uses `zig ast-check` for linting zig files

## Demo

Example of linting a file.

![Linter demo](/linter_demo.gif)

## Instructions

1. To install any linter first copy the `linter.lua` file to the folder
`data/plugins/` of the lite editor which has the needed foundation for the linters.
2. Copy the specific linters you want to use to the same folder.
3. Make sure you have the commands needed for each linter to use them.
4. If you want to configure options in some of the linters you can edit your `data/user/init.lua`

```lua
local config = require "core.config"
local insert = table.insert

-- [[ Each linter will load the arguments from a table in config.<linter_name>_args ]]

-- Mark global as known to the linter
insert(config.luacheck_args, "--new-globals=love")

-- Add error reporting in fuctions which exceed cyclomatic complexity
insert(config.luacheck_args, "--max-cyclomatic-complexity=4")

-- Add warnings if lines pass a maximum length
insert(config.luacheck_args, "--max-line-length=80")
```

## Linter Fields

**file\_patterns** {String} - List of patterns to match the files to which the
linter is run.

**warning\_pattern** String | Function - Matches the line, column and the
description for each warning(In this order). If the matching is complex and
cannot be addressed with a pattern directly a function can be used.

**warning\_pattern\_order** {line=Int, col=Int, message=Int} [optional] - Allows us
to change what is expected from the pattern when the order of the elements in
the warning is not _line -> col -> message_.

**column\_starts\_at\_zero** Bool [optional] - Is useful for some linters which have
the column number starting at zero instead of starting at one.

**command** String - Command that is run to execute the linter. It can receive a
$FILENAME name in the middle of the command which will be replaced with the name
of the file which is being edited when the linter is run.

**deduplicate** Bool [optional] - Prevent duplicated warnings. Only needed in
specific cases because some linters work with whole packages instead of a
specific file and report the same warning for the same file multiple times.

**args** {String} - Arguments to be passed to the linter in the command
line call. Will replace the $ARGS in the command. Usually this table comes from
_config.\<linter\>\_args_. This is done so the user can add it's own specific
configurations to the linter in his own user file.

**expected\_exitcodes** {Int} - Exit codes expected when the linter doesn't crash
so we can report when there is an unexpected crash.

## Configurations

The base linter code also allows some configurations that apply to all linters.
You can set them in you user file - `data/user/init.lua`.

The available configurations are:
* linter\_box\_line\_limit - Number of columns in the warning box
* linter\_scan\_interval - Seconds between checks for saves
* warning\_font - Font to be used inside the warning box

Example configuration:
```lua
config.warning_font = renderer.font.load(EXEDIR .. "/data/fonts/monospace.ttf", 13.5 * SCALE)
```
