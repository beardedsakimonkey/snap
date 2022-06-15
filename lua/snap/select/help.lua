local M = {}
M.select = function(selection, winnr)
  return vim.api.nvim_command(string.format("help %s", tostring(selection)))
end
return M
