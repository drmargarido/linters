# linters
Linters for https://github.com/rxi/lite

## Available linters

* linter\_ameba - Uses ameba for crystal files
* linter\_dscanner - Uses dscanner for d files
* linter\_eslint - Uses eslint for javascript files
* linter\_flake8 - Uses flake8 for python files
* linter\_gocompiler - Uses the go vet command to display compilation errors in golang files
* linter\_golint - Uses golint for golang files
* linter\_luacheck - Uses luacheck for lua files
* linter\_teal - Uses tl check for teal files
* linter\_nim - Uses nim check for nim files
* linter\_php - Uses built-in php binary -l flag for php files
* linter\_pylint - Uses pylint for python files
* linter\_shellcheck - Uses shellcheck linter for shell script files
* linter\_standard - Uses standard linter for javascript files

## Demo

Example of linting a file.

![Linter demo](/linter_demo.gif)

## Instructions

1. To install any linter first copy the `linter.lua` file to the folder
`data/plugins/` of the lite editor which has the needed foundation for the linters.
2. Copy the specific linters you want to use to the same folder.
3. Make sure you have the commands needed for each linter to use them.
4. If you want to configure options in some of the linters you can edit you `data/user/init.lua`

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
