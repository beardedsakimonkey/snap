local M = {}
M.select = function(result, winnr)
  local buffer = vim.fn.bufnr(result.filename, true)
  vim.api.nvim_buf_set_option(buffer, "buflisted", true)
  vim.api.nvim_win_set_buf(winnr, buffer)
  return vim.api.nvim_win_set_cursor(winnr, {result.row, 0})
end
return M
