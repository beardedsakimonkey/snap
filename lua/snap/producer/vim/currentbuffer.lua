local snap = require("snap")
local function _3_(_1_)
  local _arg_2_ = _1_
  local winnr = _arg_2_["winnr"]
  local bufnr
  local function _5_()
    local _4_ = winnr
    local function _6_(...)
      return vim.api.nvim_win_get_buf(_4_, ...)
    end
    return _6_
  end
  bufnr = snap.sync(_5_())
  local filename
  local function _8_()
    local _7_ = bufnr
    local function _9_(...)
      return vim.api.nvim_buf_get_name(_7_, ...)
    end
    return _9_
  end
  filename = snap.sync(_8_())
  local contents
  local function _11_()
    local _10_ = bufnr
    local function _12_(...)
      return vim.api.nvim_buf_get_lines(_10_, 0, -1, false, ...)
    end
    return _12_
  end
  contents = snap.sync(_11_())
  local results = {}
  for row, line in ipairs(contents) do
    table.insert(results, snap.with_metas(line, {filename = filename, row = row}))
  end
  return coroutine.yield(results)
end
return _3_
