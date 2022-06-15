local M = {}
local function lines()
  return vim.api.nvim_get_option("lines")
end
local function columns()
  return vim.api.nvim_get_option("columns")
end
local function middle(total, size)
  return math.floor(((total - size) / 2))
end
local function from_bottom(size, offset)
  return (lines() - size - offset)
end
local function size(_25width, _25height)
  return {width = math.floor((columns() * _25width)), height = math.floor((lines() * _25height))}
end
M["%centered"] = function(_25width, _25height)
  local _let_1_ = size(_25width, _25height)
  local width = _let_1_["width"]
  local height = _let_1_["height"]
  return {width = width, height = height, row = middle(lines(), height), col = middle(columns(), width)}
end
M["%bottom"] = function(_25width, _25height)
  local _let_2_ = size(_25width, _25height)
  local width = _let_2_["width"]
  local height = _let_2_["height"]
  return {width = width, height = height, row = from_bottom(height, 8), col = middle(columns(), width)}
end
M["%top"] = function(_25width, _25height)
  local _let_3_ = size(_25width, _25height)
  local width = _let_3_["width"]
  local height = _let_3_["height"]
  return {width = width, height = height, row = 5, col = middle(columns(), width)}
end
M.centered = function()
  return M["%centered"](0.9, 0.7)
end
M.bottom = function()
  local lines0 = vim.api.nvim_get_option("lines")
  local height = math.floor((lines0 * 0.5))
  local width = vim.api.nvim_get_option("columns")
  local col = 0
  local row = (lines0 - height - 4)
  return {width = width, height = height, col = col, row = row}
end
M.top = function()
  return M["%top"](0.9, 0.7)
end
return M
