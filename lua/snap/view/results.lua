local size = require("snap.view.size")
local buffer = require("snap.common.buffer")
local window = require("snap.common.window")
local register = require("snap.common.register")
local M = {}
local function layout(config)
  local _let_1_ = config.layout()
  local width = _let_1_["width"]
  local height = _let_1_["height"]
  local row = _let_1_["row"]
  local col = _let_1_["col"]
  local _2_
  if config["has-views"]() then
    _2_ = (math.floor((width * size["view-width"])) - size.padding - size.padding)
  else
    _2_ = width
  end
  local _4_
  if config.reverse then
    _4_ = (row + size.border + size.padding + size.padding)
  else
    _4_ = row
  end
  return {width = _2_, height = (height - size.border - size.border - size.padding), row = _4_, col = col, focusable = false}
end
M.create = function(config)
  local bufnr = buffer.create()
  local layout_config = layout(config)
  local winnr = window.create(bufnr, layout_config)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "prompt")
  vim.api.nvim_buf_set_option(bufnr, "textwidth", 0)
  vim.api.nvim_buf_set_option(bufnr, "wrapmargin", 0)
  vim.api.nvim_win_set_option(winnr, "wrap", false)
  vim.api.nvim_win_set_option(winnr, "cursorline", true)
  vim.api.nvim_win_set_option(winnr, "winhl", "CursorLine:SnapSelect,Normal:SnapNormal,FloatBorder:SnapBorder")
  local function delete()
    if vim.api.nvim_win_is_valid(winnr) then
      window.close(winnr)
    else
    end
    if vim.api.nvim_buf_is_valid(bufnr) then
      return buffer.delete(bufnr, {force = true})
    else
      return nil
    end
  end
  local function update(view)
    if vim.api.nvim_win_is_valid(winnr) then
      local layout_config0 = layout(config)
      window.update(winnr, layout_config0)
      vim.api.nvim_win_set_option(winnr, "cursorline", true)
      do end (view)["height"] = layout_config0.height
      view["width"] = layout_config0.width
      return nil
    else
      return nil
    end
  end
  local view = {update = update, delete = delete, bufnr = bufnr, winnr = winnr, width = layout_config.width, height = layout_config.height}
  vim.api.nvim_command("augroup SnapResultsViewResize")
  vim.api.nvim_command("autocmd!")
  local function _9_()
    return view:update()
  end
  vim.api.nvim_command(string.format("autocmd VimResized * %s", register["get-autocmd-call"]("VimResized", _9_)))
  vim.api.nvim_command("augroup END")
  return view
end
return M
