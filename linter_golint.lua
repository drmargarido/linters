local core = require "core"
local style = require "core.style"
local config = require "core.config"
local DocView = require "core.docview"
local common = require "core.common"

local default_color = { common.color "#ffff66" }

local cache = {}
local hovered_item = nil

config.max_box_chars = 80

local function run_lint_cmd(path)
  local fp = io.popen("golint "..path, "r")
  local res = fp:read("*a")
  local success = fp:close()
  return res:gsub("%\n$", ""), success
end

local function get_file_warnings(warnings, path)
  local w_text = run_lint_cmd(path)
  local pattern = "[^:]:(%d+):(%d+):%s?([^\n]*)"
  for line, col, warn in w_text:gmatch(pattern) do
    if not warnings[line] then
      warnings[line] = {}
    end
    local w = {}
    w.col = col
    w.text = warn
    table.insert(warnings[line], w)
  end
end

local function get_cached(filename)
  local t = cache[filename]
  if not t then
    t = {}
    t.filename = filename
    t.path = system.absolute_path(filename or "")
    local info = system.get_file_info(filename)
    if info then
      t.time = info.modified
    end
    t.warnings = {}
    get_file_warnings(t.warnings, t.path)
    cache[filename] = t
  end
  return t
end

local function get_word_limits(v, line_text, x, col)
  local _, e = line_text:sub(col):find("%a*")
  e = e + col - 1
  local font = v:get_font()
  local x1 = x + font:get_width(line_text:sub(1, col - 1))
  local x2 = x + font:get_width(line_text:sub(1, e))
  return x1, x2
end

local on_mouse_moved = DocView.on_mouse_moved
function DocView:on_mouse_moved(px, py)
  on_mouse_moved(self, px, py)

  local doc = self.doc
  local f = doc.filename
  if not f or not f:find("%.go$") then return end

  -- Detect if any warning is hovered
  local cached = get_cached(f)
  for line, warnings in pairs(cached.warnings) do
    local text = doc.lines[tonumber(line)]
    for _, warning in ipairs(warnings) do
      local x, y = self:get_line_screen_position(line)
      local x1, x2 = get_word_limits(self, text, x, warning.col)
      local h = self:get_line_height()
      if px > x1 and px <= x2 and py > y and py <= y + h then
        hovered_item = warning
        hovered_item.x = x1
        hovered_item.y = y
        return
      end
    end
  end

  hovered_item = nil
end

local draw_line_text = DocView.draw_line_text
function DocView:draw_line_text(idx, x, y)
  draw_line_text(self, idx, x, y)

  -- Draws lines in linted places
  local doc = self.doc
  local f = doc.filename
  if not f or not f:find("%.go$") then return end

  local cached = get_cached(f)
  local line_warnings = cached.warnings[tostring(idx)]
  if not line_warnings then return end

  local text = doc.lines[idx]
  for _, warning in ipairs(line_warnings) do
    local x1, x2 = get_word_limits(self, text, x, warning.col)
    local color = style.linter_warning or default_color
    local h = style.divider_size
    local line_h = self:get_line_height()
    renderer.draw_rect(x1, y + line_h - h, x2 - x1, h, color)
  end
end

local function draw_warning_box(av)
  local font = av:get_font()
  local th = font:get_height()
  local pad = style.padding
  local max_box_width = config.max_box_chars * font:get_width("a")

  local text_lines = {}
  local lines = 0
  local remaining_text = hovered_item.text
  while remaining_text:len() > 0 do
    local line_text = remaining_text:sub(1, config.max_box_chars)
    if line_text:len() == config.max_box_chars then
      -- Make the last word of the line not be broken in half
      local s = line_text:find("(%s)[%w%p]+$")
      if not s then s = config.max_box_chars end
      line_text = line_text:sub(1, s)
      remaining_text = remaining_text:sub(s+1)
    else
      remaining_text = remaining_text:sub(config.max_box_chars)
    end
    table.insert(text_lines, line_text)

    lines = lines + 1
  end

  -- draw background rect
  local rx = hovered_item.x - pad.x
  local ry = hovered_item.y
  local text_width = 0
  for _, line in ipairs(text_lines) do
    local w = font:get_width(line)
    text_width = math.max(text_width, w)
  end
  local rw = text_width + pad.x * 2
  local rh = (th * lines) + pad.y * 2
  renderer.draw_rect(rx, ry + th, rw, rh, style.background3)

  -- draw text
  local color = style.text
  local x = rx + pad.x
  for i, line in ipairs(text_lines) do
    local y = ry + pad.y + (th * i)
    renderer.draw_text(font, line, x, y, color)
  end
end

local function check_cache(filename)
  local info = system.get_file_info(filename)
  if not info then return end
  local cached = get_cached(filename)
  if cached and cached.time ~= info.modified then
    cache[filename] = nil
  end
end

local draw = DocView.draw
function DocView:draw()
  draw(self)

  if self.doc.filename then
    check_cache(self.doc.filename)
  end

  if not hovered_item then return end
  draw_warning_box(self)
end

