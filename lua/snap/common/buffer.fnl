(local M {})

;; Creates a namespace for highlighting
(local namespace (vim.api.nvim_create_namespace :Snap))

(fn M.set-lines [bufnr start end lines]
  "Helper to set lines to results view"
  (vim.api.nvim_buf_set_lines bufnr start end false lines))

(fn M.add-highlight [bufnr hl row col-start col-end]
  "Helper function for adding highlighting"
  (vim.api.nvim_buf_add_highlight bufnr namespace hl row col-start col-end))

(fn M.add-selected-highlight [bufnr row]
  "Helper function for adding selected highlighting"
  (vim.api.nvim_buf_add_highlight bufnr namespace :SnapMultiSelect (- row 1) 0 -1))

(fn M.add-positions-highlight [bufnr row positions]
  "Helper function for adding positions highlights"
  (local line (- row 1))
  (each [_ col (ipairs positions)]
    (M.add-highlight bufnr :SnapPosition line (- col 1) col)))

(fn M.create []
  "Creates a scratch buffer"
  (vim.api.nvim_create_buf false true))

(fn M.delete [bufnr]
  "Deletes a scratch buffer"
  (vim.api.nvim_buf_delete bufnr {:force true}))

M
