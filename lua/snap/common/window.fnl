(local M {})

(fn M.create [bufnr {: width : height : row : col : focusable}]
  "Creates a window with specified options"
  (vim.api.nvim_open_win bufnr 0 {: width
                          : height
                          : row
                          : col
                          : focusable
                          :noautocmd true
                          :relative :editor
                          :anchor :NW
                          :style :minimal
                          :border ["╭" "─" "╮" "│" "╯" "─" "╰" "│"]}))

(fn M.update [winnr {: width : height : row : col : focusable}]
  "Updates a window with specified options"
  (when (vim.api.nvim_win_is_valid winnr)
    (vim.api.nvim_win_set_config winnr {: width
                                        : height
                                        : row
                                        : col
                                        : focusable
                                        :relative :editor})))

(fn M.close [winnr]
  (vim.api.nvim_win_close winnr true))
M
