(local M {})

(fn M.select [selection winnr]
  (vim.api.nvim_command (string.format "help %s" (tostring selection))))
M
