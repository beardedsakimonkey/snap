local M = {}
M.select = function(selection, winnr)
  local _let_1_ = selection
  local bufnr = _let_1_["bufnr"]
  local lnum = _let_1_["lnum"]
  local col = _let_1_["col"]
  vim.api.nvim_win_set_buf(winnr, bufnr)
  vim.api.nvim_win_set_option(winnr, "relativenumber", true)
  return vim.api.nvim_win_set_cursor(winnr, {lnum, col})
end
return M
