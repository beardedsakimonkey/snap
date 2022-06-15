(local M {})

(fn M.select [selection winnr]
  (vim.schedule (partial vim.api.nvim_set_current_dir selection)))
M
