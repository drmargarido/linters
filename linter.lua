local style = require "core.style"
local config = require "core.config"
local DocView = require "core.docview"
local RootView = require "core.rootview"
local Doc = require "core.doc"

local cache = setmetatable({}, { __mode = "k" })
local hovered_item = nil

config.linter_box_line_limit = 80

local linters = {}


local function run_lint_cmd(path, linter)
  local cmd = linter.command:gsub("$FILENAME", path)
  local fp = io.popen(cmd, "r")
  local res = fp:read("*a")
  local success = fp:close()
  return res:gsub("%\n$", ""), success
end


local function get_file_warnings(warnings, path, linter)
  local w_text = run_lint_cmd(path, linter)
  local pattern = linter.warning_pattern
  for line, col, warn in w_text:gmatch(pattern) do
    line = tonumber(line)
    col = tonumber(col)
    if not warnings[line] then
      warnings[line] = {}
    end
    local w = {}
    w.col = col
    w.text = warn
    table.insert(warnings[line], w)
  end
end


local function matches_any(filename, patterns)
  for _, ptn in ipairs(patterns) do
    if filename:find(ptn) then return true end
  end
end


local function matching_linters(filename)
  local matched = {}
  for _, l in ipairs(linters) do
    if matches_any(filename, l.file_patterns) then
      table.insert(matched, l)
    end
  end
  return matched
end


local function update_cache(doc)
  local d = {}
  if doc.filename then
    local path = system.absolute_path(doc.filename)
    local lints = matching_linters(doc.filename)
    for _, l in ipairs(lints) do
      get_file_warnings(d, path, l)
    end
    for idx, t in pairs(d) do
      t.line_text = doc.lines[idx]
    end
  end
  cache[doc] = d
end


local function get_word_limits(v, line_text, x, col)
  if col == 0 then col = 1 end
  local _, e = line_text:sub(col):find(config.symbol_pattern)
  if not e or e <= 0 then e = 1 end
  e = e + col - 1

  local font = v:get_font()
  local x1 = x + font:get_width(line_text:sub(1, col - 1))
  local x2 = x + font:get_width(line_text:sub(1, e))
  return x1, x2
end


local clean = Doc.clean
function Doc:clean(...)
  clean(self, ...)
  update_cache(self)
end

local new = Doc.new
function Doc:new(...)
  new(self, ...)
  update_cache(self)
end


local on_mouse_wheel = DocView.on_mouse_wheel
function DocView:on_mouse_wheel(...)
  on_mouse_wheel(self, ...)
  hovered_item = nil
end


local on_mouse_moved = DocView.on_mouse_moved
function DocView:on_mouse_moved(px, py, ...)
  on_mouse_moved(self, px, py, ...)

  local doc = self.doc
  local cached = cache[doc]
  if not cached then return end

  -- Detect if any warning is hovered
  local hovered = {}
  local hovered_w = {}
  for line, warnings in pairs(cached) do
    local text = doc.lines[line]
    if text == warnings.line_text then
      for _, warning in ipairs(warnings) do
        local x, y = self:get_line_screen_position(line)
        local x1, x2 = get_word_limits(self, text, x, warning.col)
        local h = self:get_line_height()
        if px > x1 and px <= x2 and py > y and py <= y + h then
          table.insert(hovered_w, warning.text)
          hovered.x = px
          hovered.y = y + h
        end
      end
    end
  end
  hovered.warnings = hovered_w
  if #hovered.warnings ~= 0 then
    hovered_item = hovered
  else
    hovered_item = nil
  end
end


local draw_line_text = DocView.draw_line_text
function DocView:draw_line_text(idx, x, y)
  draw_line_text(self, idx, x, y)

  local doc = self.doc
  local cached = cache[doc]
  if not cached then return end

  local line_warnings = cached[idx]
  if not line_warnings then return end

  -- Don't draw underlines if line text has changed
  if line_warnings.line_text ~= doc.lines[idx] then
    return
  end

  -- Draws lines in linted places
  local text = doc.lines[idx]
  for _, warning in ipairs(line_warnings) do
    local x1, x2 = get_word_limits(self, text, x, warning.col)
    local color = style.linter_warning or style.syntax.literal
    local h = style.divider_size
    local line_h = self:get_line_height()
    renderer.draw_rect(x1, y + line_h - h, x2 - x1, h, color)
  end
end


local function text_in_lines(text, max_len)
  local text_lines = {}
  local line = ""
  for word, seps in text:gmatch("([%S]+)([%c%s]*)") do
    if #line + #word > max_len then
      table.insert(text_lines, line)
      line = ""
    end
    line=line..word
    for sep in seps:gmatch(".") do
      if sep == "\n" then
        table.insert(text_lines, line)
        line = ""
      else
        line=line..sep
      end
    end
  end
  if #line > 0 then
    table.insert(text_lines, line)
  end
  return text_lines
end


local function draw_warning_box()
  local font = style.font
  local th = font:get_height()
  local pad = style.padding

  local max_len = config.linter_box_line_limit
  local full_text = table.concat(hovered_item.warnings, "\n\n")
  local lines = text_in_lines(full_text, max_len)

  -- draw background rect
  local rx = hovered_item.x - pad.x
  local ry = hovered_item.y
  local text_width = 0
  for _, line in ipairs(lines) do
    local w = font:get_width(line)
    text_width = math.max(text_width, w)
  end
  local rw = text_width + pad.x * 2
  local rh = (th * #lines) + pad.y * 2
  renderer.draw_rect(rx, ry, rw, rh, style.background3)

  -- draw text
  local color = style.text
  local x = rx + pad.x
  for i, line in ipairs(lines) do
    local y = ry + pad.y + th * (i - 1)
    renderer.draw_text(font, line, x, y, color)
  end
end


local draw = RootView.draw
function RootView:draw()
  draw(self)
  if hovered_item then draw_warning_box() end
end


return {
  add_language = function(lang)
    table.insert(linters, lang)
  end
}
