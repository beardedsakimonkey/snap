(local M {})

(fn M.select [selection winnr]
  (vim.api.nvim_put [(tostring selection)] "c" true true))
M
