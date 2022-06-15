local size = require("snap.view.size")
local buffer = require("snap.common.buffer")
local window = require("snap.common.window")
local tbl = require("snap.common.tbl")
local register = require("snap.common.register")
local M = {}
local function layout(config)
  local _let_1_ = config.layout()
  local width = _let_1_["width"]
  local height = _let_1_["height"]
  local row = _let_1_["row"]
  local col = _let_1_["col"]
  local index = (config.index - 1)
  local border = (index * size.border)
  local padding = (index * size.padding)
  local total_borders = ((config["total-views"] - 1) * size.border)
  local total_paddings = ((config["total-views"] - 1) * size.padding)
  local sizes = tbl.allocate((height - total_borders - total_paddings), config["total-views"])
  local height0 = sizes[config.index]
  local col_offset = math.floor((width * size["view-width"]))
  return {width = (width - col_offset - size.padding - size.padding - size.border), height = height0, row = (row + tbl.sum(tbl.take(sizes, index)) + border + padding), col = (col + col_offset + (size.border * 2) + size.padding), focusable = false}
end
M.create = function(config)
  local bufnr = buffer.create()
  local layout_config = layout(config)
  local winnr = window.create(bufnr, layout_config)
  vim.api.nvim_win_set_option(winnr, "cursorline", false)
  vim.api.nvim_win_set_option(winnr, "cursorcolumn", false)
  vim.api.nvim_win_set_option(winnr, "wrap", false)
  vim.api.nvim_win_set_option(winnr, "winhl", "Normal:SnapNormal,FloatBorder:SnapBorder")
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
  vim.api.nvim_command("augroup SnapViewResize")
  vim.api.nvim_command("autocmd!")
  local function _5_()
    return view:update()
  end
  vim.api.nvim_command(string.format("autocmd VimResized * %s", register["get-autocmd-call"]("VimResized", _5_)))
  vim.api.nvim_command("augroup END")
  return view
end
return M
