local snap
do
  local p = package.loaded.snap
  if ("table" == type(p)) then
    snap = p
  else
    snap = require("snap")
  end
end
local function create_slow_api()
  local slow_api = {pending = false, value = nil}
  slow_api.schedule = function(fnc)
    slow_api["pending"] = true
    local function _2_()
      slow_api["value"] = fnc()
      do end (slow_api)["pending"] = false
      return nil
    end
    return vim.schedule(_2_)
  end
  return slow_api
end
local function _5_(_3_)
  local _arg_4_ = _3_
  local producer = _arg_4_["producer"]
  local request = _arg_4_["request"]
  local on_end = _arg_4_["on-end"]
  local on_value = _arg_4_["on-value"]
  local on_tick = _arg_4_["on-tick"]
  if not request.canceled() then
    local idle = vim.loop.new_idle()
    local thread = coroutine.create(producer)
    local slow_api = create_slow_api()
    local function stop()
      idle:stop()
      idle = nil
      thread = nil
      slow_api = nil
      if on_end then
        return on_end()
      else
        return nil
      end
    end
    local function start()
      if slow_api.pending then
        return nil
      elseif (coroutine.status(thread) ~= "dead") then
        local _, value, on_cancel = coroutine.resume(thread, request, slow_api.value)
        do
          local _7_ = type(value)
          if (_7_ == "function") then
            slow_api.schedule(value)
          elseif (_7_ == "nil") then
            stop()
          else
            local function _8_()
              return (value == snap.continue_value)
            end
            if ((_7_ == "table") and _8_()) then
              if request.canceled() then
                if on_cancel then
                  on_cancel()
                else
                end
                stop()
              else
              end
            elseif true then
              local _0 = _7_
              if on_value then
                on_value(value)
              else
              end
            else
            end
          end
        end
        if on_tick then
          return on_tick()
        else
          return nil
        end
      else
        return stop()
      end
    end
    return idle:start(start)
  else
    return nil
  end
end
return _5_
