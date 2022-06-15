local M = {}
M.select = function(selection, winnr, type)
  local path = vim.fn.fnamemodify(tostring(selection), ":p")
  local buffer = vim.fn.bufnr(path, true)
  vim.api.nvim_buf_set_option(buffer, "buflisted", true)
  local _1_ = type
  if (_1_ == nil) then
    if (winnr ~= false) then
      return vim.api.nvim_win_set_buf(winnr, buffer)
    else
      return nil
    end
  elseif (_1_ == "vsplit") then
    vim.api.nvim_command("vsplit")
    return vim.api.nvim_win_set_buf(0, buffer)
  elseif (_1_ == "split") then
    vim.api.nvim_command("split")
    return vim.api.nvim_win_set_buf(0, buffer)
  elseif (_1_ == "tab") then
    vim.api.nvim_command("tabnew")
    return vim.api.nvim_win_set_buf(0, buffer)
  else
    return nil
  end
end
M.multiselect = function(selections, winnr)
  for index, selection in ipairs(selections) do
    local function _4_()
      if (#selections == index) then
        return winnr
      else
        return false
      end
    end
    select(selection, _4_())
  end
  return nil
end
return M
