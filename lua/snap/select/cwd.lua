local M = {}
M.select = function(selection, winnr)
  local function _2_()
    local _1_ = selection
    local function _3_(...)
      return vim.api.nvim_set_current_dir(_1_, ...)
    end
    return _3_
  end
  return vim.schedule(_2_())
end
return M
