local M = {}
local namespace = vim.api.nvim_create_namespace("Snap")
M["set-lines"] = function(bufnr, start, _end, lines)
  return vim.api.nvim_buf_set_lines(bufnr, start, _end, false, lines)
end
M["add-highlight"] = function(bufnr, hl, row, col_start, col_end)
  return vim.api.nvim_buf_add_highlight(bufnr, namespace, hl, row, col_start, col_end)
end
M["add-selected-highlight"] = function(bufnr, row)
  return vim.api.nvim_buf_add_highlight(bufnr, namespace, "SnapMultiSelect", (row - 1), 0, -1)
end
M["add-positions-highlight"] = function(bufnr, row, positions)
  local line = (row - 1)
  for _, col in ipairs(positions) do
    M["add-highlight"](bufnr, "SnapPosition", line, (col - 1), col)
  end
  return nil
end
M.create = function()
  return vim.api.nvim_create_buf(false, true)
end
M.delete = function(bufnr)
  return vim.api.nvim_buf_delete(bufnr, {force = true})
end
return M
