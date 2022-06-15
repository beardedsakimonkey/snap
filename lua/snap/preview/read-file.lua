local snap = require("snap")
local snap_io = snap.get("common.io")
local function _1_(path, on_resume)
  local handle = io.popen(string.format("file -n -b --mime-encoding %s", path))
  local encoding = string.gsub(handle:read("*a"), "^%s*(.-)%s*$", "%1")
  handle:close()
  local preview = nil
  if (encoding == "binary") then
    preview = {"Binary file"}
  else
    local databuffer = ""
    local reader = coroutine.create(snap_io.read)
    local function free(cancel)
      if cancel then
        cancel()
      else
      end
      databuffer = ""
      reader = nil
      return nil
    end
    while (coroutine.status(reader) ~= "dead") do
      if on_resume then
        on_resume()
      else
      end
      local _, cancel, data = coroutine.resume(reader, path)
      if (data ~= nil) then
        databuffer = (databuffer .. data)
      else
      end
      local function _6_()
        local _5_ = cancel
        local function _7_(...)
          return free(_5_, ...)
        end
        return _7_
      end
      snap.continue(_6_())
    end
    preview = {}
    for line in databuffer:gmatch("([^\r\n]*)[\r\n]?") do
      table.insert(preview, line)
    end
    free()
  end
  return preview
end
return _1_
