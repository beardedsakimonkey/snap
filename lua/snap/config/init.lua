local snap = require("snap")
local tbl = require("snap.common.tbl")
local M = {}
local default_min_width = (80 * 2)
local function preview_disabled(min_width)
  return (vim.api.nvim_get_option("columns") <= (min_width or default_min_width))
end
local function hide_views(config)
  local _1_ = type(config.preview)
  if (_1_ == "nil") then
    return preview_disabled(config.preview_min_width)
  elseif (_1_ == "boolean") then
    return ((config.preview == false) or preview_disabled(config.preview_min_width))
  elseif (_1_ == "function") then
    return not config.preview()
  else
    return nil
  end
end
local function format_prompt(suffix, prompt)
  return string.format("%s%s", prompt, (suffix or ">"))
end
local function with(fnc, defaults)
  local function _3_(config)
    return fnc(tbl.merge(defaults, config))
  end
  return _3_
end
local function file_producer_by_kind(config, kind)
  local producer
  do
    local _4_ = kind
    if (_4_ == "ripgrep.file") then
      producer = snap.get("producer.ripgrep.file")
    elseif (_4_ == "fd.file") then
      producer = snap.get("producer.fd.file")
    elseif (_4_ == "vim.oldfile") then
      producer = snap.get("producer.vim.oldfile")
    elseif (_4_ == "vim.buffer") then
      producer = snap.get("producer.vim.buffer")
    elseif (_4_ == "git.file") then
      producer = snap.get("producer.git.file")
    else
      local function _5_()
        local p = _4_
        return (type(p) == "function")
      end
      if ((nil ~= _4_) and _5_()) then
        local p = _4_
        producer = p
      elseif true then
        local _ = _4_
        producer = assert(false, "file.producer is invalid")
      else
        producer = nil
      end
    end
  end
  if (config.args and ((kind == "ripgrep.file") or (kind == "fd.file") or (kind == "git.file"))) then
    producer = producer.args(config.args)
  elseif (config.hidden and ((kind == "ripgrep.file") or (kind == "fd.file"))) then
    producer = producer.hidden
  else
  end
  return producer
end
local function file_prompt_by_kind(kind)
  local _8_ = kind
  if (_8_ == "ripgrep.file") then
    return "Rg Files"
  elseif (_8_ == "fd.file") then
    return "Fd Files"
  elseif (_8_ == "vim.oldfile") then
    return "Old Files"
  elseif (_8_ == "vim.buffer") then
    return "Buffers"
  elseif (_8_ == "git.file") then
    return "Git Files"
  elseif true then
    local _ = _8_
    return "Custom Files"
  else
    return nil
  end
end
local function current_word()
  return vim.fn.expand("<cword>")
end
local function current_selection()
  local register = vim.fn.getreg("\"")
  vim.api.nvim_exec("normal! y", false)
  local filter = vim.fn.trim(vim.fn.getreg("@"))
  vim.fn.setreg("\"", register)
  return filter
end
local function get_initial_filter(config)
  if (config.filter_with ~= nil) then
    local _10_ = config.filter_with
    if (_10_ == "cword") then
      return current_word()
    elseif (_10_ == "selection") then
      return current_selection()
    elseif true then
      local _ = _10_
      return assert(false, "config.filter_with must be a string cword, or selection")
    else
      return nil
    end
  elseif (config.filter ~= nil) then
    local _12_ = type(config.filter)
    if (_12_ == "function") then
      return config.filter()
    elseif (_12_ == "string") then
      return config.filter
    elseif true then
      local _ = _12_
      return assert(false, "config.filter must be a string or function")
    else
      return nil
    end
  else
    return nil
  end
end
local function file(_self, config)
  assert((type(config) == "table"))
  if config.prompt then
    assert((type(config.prompt) == "string"), "file.prompt must be a string")
  else
  end
  if config.suffix then
    assert((type(config.suffix) == "string"), "file.suffix must be a string")
  else
  end
  if config.layout then
    assert((type(config.layout) == "function"), "file.layout must be a function")
  else
  end
  if config.args then
    assert((type(config.args) == "table"), "file.args must be a table")
  else
  end
  if config.hidden then
    assert((type(config.hidden) == "boolean"), "file.hidden must be a boolean")
  else
  end
  if config.try then
    assert((type(config.try) == "table"), "file.try must be a table")
  else
  end
  if config.combine then
    assert((type(config.combine) == "table"), "file.combine must be a table")
  else
  end
  if config.reverse then
    assert((type(config.reverse) == "boolean"), "file.reverse must be a boolean")
  else
  end
  if config.preview_min_width then
    assert((type(config.preview_min_width) == "number"), "file.preview-min-with must be a number")
  else
  end
  if config.mappings then
    assert((type(config.mappings) == "table"), "file.mappings must be a table")
  else
  end
  if config.preview then
    assert(vim.tbl_contains({"function", "boolean"}, type(config.preview)), "file.preview must be a boolean or a function")
  else
  end
  assert((config.producer or config.try or config.combine), "one of file.producer, file.try or file.combine must be set")
  assert(not (config.producer and config.try), "file.try and file.producer can not be used together")
  assert(not (config.producer and config.combine), "file.combine and file.producer can not be used together")
  assert(not (config.try and config.combine), "file.try and file.combine can not be used together")
  assert(not (config.hidden and config.args), "file.args and file.hidden can not be used together")
  local by_kind
  do
    local _26_ = config
    local function _27_(...)
      return file_producer_by_kind(_26_, ...)
    end
    by_kind = _27_
  end
  local consumer_kind = (config.consumer or "fzf")
  local producer
  if config.try then
    producer = snap.get("consumer.try")(unpack(vim.tbl_map(by_kind, config.try)))
  elseif config.combine then
    producer = snap.get("consumer.combine")(unpack(vim.tbl_map(by_kind, config.combine)))
  else
    producer = by_kind(config.producer)
  end
  local consumer
  do
    local _29_ = consumer_kind
    if (_29_ == "fzf") then
      consumer = snap.get("consumer.fzf")
    elseif (_29_ == "fzy") then
      consumer = snap.get("consumer.fzy")
    else
      local function _30_()
        local c = _29_
        return (type(c) == "function")
      end
      if ((nil ~= _29_) and _30_()) then
        local c = _29_
        consumer = c
      elseif true then
        local _ = _29_
        consumer = assert(false, "file.consumer is invalid")
      else
        consumer = nil
      end
    end
  end
  local add_prompt_suffix
  do
    local _32_ = config.suffix
    local function _33_(...)
      return format_prompt(_32_, ...)
    end
    add_prompt_suffix = _33_
  end
  local prompt
  local function _34_()
    if config.prompt then
      return config.prompt
    elseif config.producer then
      return file_prompt_by_kind(config.producer)
    elseif config.try then
      return table.concat(vim.tbl_map(file_prompt_by_kind, config.try), " or ")
    elseif config.combine then
      return table.concat(vim.tbl_map(file_prompt_by_kind, config.combine), " + ")
    else
      return nil
    end
  end
  prompt = add_prompt_suffix(_34_())
  local select_file = snap.get("select.file")
  local function _35_()
    local hide_views0
    do
      local _36_ = config
      local function _37_(...)
        return hide_views(_36_, ...)
      end
      hide_views0 = _37_
    end
    local reverse = (config.reverse or false)
    local layout = (config.layout or nil)
    local mappings = (config.mappings or nil)
    local producer0 = consumer(producer)
    local select = select_file.select
    local multiselect = select_file.multiselect
    local initial_filter = get_initial_filter(config)
    local views = {snap.get("preview.file")}
    return snap.run({prompt = prompt, mappings = mappings, layout = layout, reverse = reverse, producer = producer0, select = select, multiselect = multiselect, views = views, hide_views = hide_views0, initial_filter = initial_filter})
  end
  return _35_
end
M["file"] = setmetatable({with = with}, {__call = file})
local function vimgrep_prompt_by_kind(kind)
  local _38_ = kind
  if (_38_ == "ripgrep.vimgrep") then
    return "Rg Vimgrep"
  elseif true then
    local _ = _38_
    return "Custom Vimgrep"
  else
    return nil
  end
end
local function vimgrep(_self, config)
  assert((type(config) == "table"))
  if config.prompt then
    assert((type(config.prompt) == "string"), "vimgrep.prompt must be a string")
  else
  end
  if config.limit then
    assert((type(config.limit) == "number"), "vimgrep.limit must be a number")
  else
  end
  if config.layout then
    assert((type(config.layout) == "function"), "vimgrep.layout must be a function")
  else
  end
  if config.args then
    assert((type(config.args) == "table"), "vimgrep.args must be a table")
  else
  end
  if config.hidden then
    assert((type(config.hidden) == "boolean"), "vimgrep.hidden must be a boolean")
  else
  end
  if config.suffix then
    assert((type(config.suffix) == "string"), "vimgrep.suffix must be a string")
  else
  end
  if config.reverse then
    assert((type(config.reverse) == "boolean"), "vimgrep.reverse must be a boolean")
  else
  end
  if config.preview then
    assert((type(config.preview) == "boolean"), "vimgrep.preview must be a boolean")
  else
  end
  if config.mappings then
    assert((type(config.mappings) == "table"), "vimgrep.mappings must be a table")
  else
  end
  local producer_kind = (config.producer or "ripgrep.vimgrep")
  local producer
  do
    local _49_ = producer_kind
    if (_49_ == "ripgrep.vimgrep") then
      producer = snap.get("producer.ripgrep.vimgrep")
    else
      local function _50_()
        local p = _49_
        return (type(p) == "function")
      end
      if ((nil ~= _49_) and _50_()) then
        local p = _49_
        producer = p
      elseif true then
        local _ = _49_
        producer = assert(false, "vimgrep.producer is invalid")
      else
        producer = nil
      end
    end
  end
  if (producer_kind == "ripgrep.vimgrep") then
    if config.args then
      producer = producer.args(config.args)
    elseif config.hidden then
      producer = producer.hidden
    else
    end
  else
  end
  local consumer
  if config.limit then
    local _54_ = config.limit
    local function _55_(...)
      return snap.get("consumer.limit")(_54_, ...)
    end
    consumer = _55_
  else
    local function _56_(producer0)
      return producer0
    end
    consumer = _56_
  end
  local format_prompt0
  do
    local _58_ = config.suffix
    local function _59_(...)
      return format_prompt(_58_, ...)
    end
    format_prompt0 = _59_
  end
  local prompt
  local function _60_()
    if config.prompt then
      return config.prompt
    elseif producer_kind then
      return vimgrep_prompt_by_kind(producer_kind)
    else
      return nil
    end
  end
  prompt = format_prompt0(_60_())
  local vimgrep_select = snap.get("select.vimgrep")
  local function _61_()
    local hide_views0
    do
      local _62_ = config
      local function _63_(...)
        return M.hide_views(_62_, ...)
      end
      hide_views0 = _63_
    end
    local reverse = (config.reverse or false)
    local layout = (config.layout or nil)
    local mappings = (config.mappings or nil)
    local producer0 = consumer(producer)
    local select = vimgrep_select.select
    local multiselect = vimgrep_select.multiselect
    local initial_filter = get_initial_filter(config)
    local views = {snap.get("preview.vimgrep")}
    return snap.run({prompt = prompt, layout = layout, reverse = reverse, mappings = mappings, producer = producer0, select = select, multiselect = multiselect, views = views, hide_views = hide_views0, initial_filter = initial_filter})
  end
  return _61_
end
M["vimgrep"] = setmetatable({with = with}, {__call = vimgrep})
return M
