local snap = require("snap")
local M = {}
M.spawn = function(cmd, args, cwd, stdin)
  local stdoutbuffer = ""
  local stderrbuffer = ""
  local handle = nil
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  local function _1_(code, signal)
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    if stdin then
      stdin:read_stop()
      stdin:close()
    else
    end
    return handle:close()
  end
  handle = vim.loop.spawn(cmd, {args = args, stdio = {stdin, stdout, stderr}, cwd = cwd}, _1_)
  local function _3_(err, data)
    assert(not err)
    if data then
      stdoutbuffer = (stdoutbuffer .. data)
      return nil
    else
      return nil
    end
  end
  stdout:read_start(_3_)
  local function _5_(err, data)
    assert(not err)
    if data then
      stderrbuffer = (stderrbuffer .. data)
      return nil
    else
      return nil
    end
  end
  stderr:read_start(_5_)
  local function kill()
    return handle:kill(vim.loop.constants.SIGTERM)
  end
  local function _7_()
    if ((handle and handle:is_active()) or (stdoutbuffer ~= "")) then
      local stdout0 = stdoutbuffer
      local stderr0 = stderrbuffer
      stdoutbuffer = ""
      stderrbuffer = ""
      return stdout0, stderr0, kill
    else
      return nil
    end
  end
  return _7_
end
local chunk_size = 10000
M.read = function(path)
  local closed = false
  local canceled = false
  local reading = true
  local databuffer = ""
  local fd = nil
  local stat = nil
  local current_offset = 0
  local function on_close(err)
    assert(not err, err)
    closed = true
    return nil
  end
  local function on_read(err, data)
    assert(not err, err)
    databuffer = data
    return nil
  end
  local function on_stat(err, s)
    assert(not err, err)
    stat = s
    return vim.loop.fs_read(fd, math.min(chunk_size, stat.size), current_offset, on_read)
  end
  local function on_open(err, f)
    assert(not err, err)
    fd = f
    return vim.loop.fs_fstat(fd, on_stat)
  end
  vim.loop.fs_open(path, "r", 438, on_open)
  local function close()
    return vim.loop.fs_close(fd, on_close)
  end
  local function cancel()
    canceled = true
    return nil
  end
  while not closed do
    if (not fd or not stat or (databuffer == "")) then
      coroutine.yield(cancel)
    else
      local data = databuffer
      databuffer = ""
      if canceled then
        close()
      elseif reading then
        current_offset = (current_offset + chunk_size)
        if (current_offset < stat.size) then
          vim.loop.fs_read(fd, chunk_size, current_offset, on_read)
        else
          reading = false
          close()
        end
      else
      end
      coroutine.yield(cancel, data)
    end
  end
  return nil
end
return M
