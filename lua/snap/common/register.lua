local M = {}
local register = {commands = {}}
M.clean = function(group)
  register[group] = nil
  return nil
end
M.run = function(group, fnc)
  local _2_
  do
    local t_1_ = register
    if (nil ~= t_1_) then
      t_1_ = (t_1_)[group]
    else
    end
    if (nil ~= t_1_) then
      t_1_ = (t_1_)[fnc]
    else
    end
    _2_ = t_1_
  end
  if _2_ then
    return register[group][fnc]()
  else
    return nil
  end
end
M["get-by-template"] = function(group, fnc, pre, post)
  local group_fns = (register[group] or {})
  local id = string.format("%s", fnc)
  do end (register)[group] = group_fns
  if (group_fns[id] == nil) then
    group_fns[id] = fnc
  else
  end
  return string.format("%slua require'snap'.register.run('%s', '%s')%s", pre, group, id, post)
end
M["get-map-call"] = function(group, fnc)
  return M["get-by-template"](group, fnc, "<Cmd>", "<CR>")
end
M["get-autocmd-call"] = function(group, fnc)
  return M["get-by-template"](group, fnc, ":", "")
end
M["buf-map"] = function(bufnr, modes, keys, fnc, opts)
  local rhs = M["get-map-call"](tostring(bufnr), fnc)
  for _, key in ipairs(keys) do
    for _0, mode in ipairs(modes) do
      vim.api.nvim_buf_set_keymap(bufnr, mode, key, rhs, (opts or {nowait = true}))
    end
  end
  return nil
end
local function handle_string(tbl)
  local _7_ = type(tbl)
  if (_7_ == "table") then
    return tbl
  elseif (_7_ == "string") then
    return {tbl}
  else
    return nil
  end
end
M.map = function(modes, keys, fnc, opts)
  local rhs = M["get-map-call"]("global", fnc)
  for _, key in ipairs(handle_string(keys)) do
    for _0, mode in ipairs(handle_string(modes)) do
      vim.api.nvim_set_keymap(mode, key, rhs, (opts or {}))
    end
  end
  return nil
end
_G.snap_commands = function()
  return vim.tbl_keys(register.commands)
end
M.command = function(name, fnc)
  if (#register.commands == 0) then
    vim.api.nvim_command("command! -nargs=1 -complete=customlist,v:lua.snap_commands Snap lua require'snap'.register.run('commands', <f-args>)")
  else
  end
  register.commands[name] = fnc
  return nil
end
return M
