local M = {}
M.select = function(selection, winnr)
  return vim.api.nvim_put({tostring(selection)}, "c", true, true)
end
return M
