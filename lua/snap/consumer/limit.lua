local snap = require("snap")
local function _1_(limit, producer)
  local function _2_(request)
    local count = 0
    for results in snap.consume(producer, request) do
      if (type(results) == "table") then
        count = (count + #results)
      else
      end
      if (count > limit) then
        request.cancel()
      else
      end
      coroutine.yield(results)
    end
    return nil
  end
  return _2_
end
return _1_
