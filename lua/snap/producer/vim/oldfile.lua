local function get_oldfiles()
  local function _1_(_241)
    return (vim.fn.empty(vim.fn.glob(_241)) == 0)
  end
  return vim.tbl_filter(_1_, vim.v.oldfiles)
end
local snap = require("snap")
local function _2_()
  return snap.sync(get_oldfiles)
end
return _2_
