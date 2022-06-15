local M = {}
local parse = require("snap.common.vimgrep.parse")
M.multiselect = function(selections, winnr)
  vim.fn.setqflist(vim.tbl_map(parse, selections))
  vim.api.nvim_command("copen")
  return vim.api.nvim_command("cfirst")
end
M.select = function(selection, winnr, type)
  local winnr0 = winnr
  local _let_1_ = parse(selection)
  local filename = _let_1_["filename"]
  local lnum = _let_1_["lnum"]
  local col = _let_1_["col"]
  local path = vim.fn.fnamemodify(filename, ":p")
  local buffer = vim.fn.bufnr(path, true)
  vim.api.nvim_buf_set_option(buffer, "buflisted", true)
  do
    local _2_ = type
    if (_2_ == nil) then
      if (winnr0 ~= false) then
        vim.api.nvim_win_set_buf(winnr0, buffer)
      else
      end
    elseif (_2_ == "vsplit") then
      vim.api.nvim_command("vsplit")
      vim.api.nvim_win_set_buf(0, buffer)
      winnr0 = vim.api.nvim_get_current_win()
    elseif (_2_ == "split") then
      vim.api.nvim_command("split")
      vim.api.nvim_win_set_buf(0, buffer)
      winnr0 = vim.api.nvim_get_current_win()
    elseif (_2_ == "tab") then
      vim.api.nvim_command("tabnew")
      vim.api.nvim_win_set_buf(0, buffer)
      winnr0 = vim.api.nvim_get_current_win()
    else
    end
  end
  return vim.api.nvim_win_set_cursor(winnr0, {lnum, col})
end
return M
