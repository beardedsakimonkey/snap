local snap = require("snap")
local general = snap.get("producer.luv.general")
local function _1_(request)
  return general({directory = true}, snap.sync(vim.fn.getcwd))
end
return _1_
