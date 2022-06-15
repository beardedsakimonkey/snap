local snap = require("snap")
local function _1_(types, cwd)
  local dirs = {cwd}
  local relative_dir
  local function _3_()
    local _2_ = cwd
    local function _4_(...)
      return vim.fn.fnamemodify(_2_, ":.", ...)
    end
    return _4_
  end
  relative_dir = snap.sync(_3_())
  while (#dirs > 0) do
    local dir = table.remove(dirs)
    local handle = vim.loop.fs_scandir(dir)
    local results = {}
    while handle do
      local name, t = vim.loop.fs_scandir_next(handle)
      if name then
        local path = (dir .. "/" .. name)
        local relative_path
        local function _6_()
          local _5_ = path
          local function _7_(...)
            return vim.fn.fnamemodify(_5_, ":.", ...)
          end
          return _7_
        end
        relative_path = snap.sync(_6_())
        if types[t] then
          table.insert(results, relative_path)
        else
        end
        if (t == "directory") then
          table.insert(dirs, path)
        else
        end
      else
        break
      end
    end
    coroutine.yield(results)
  end
  return nil
end
return _1_
