local M = {}
package.loaded["snap"] = M
local tbl = require("snap.common.tbl")
local register = require("snap.common.register")
local config = require("snap.config")
local buffer = require("snap.common.buffer")
local input = require("snap.view.input")
local results = require("snap.view.results")
local view = require("snap.view.view")
local request = require("snap.producer.request")
local create = require("snap.producer.create")
do end (M)["register"] = register
M["config"] = config
M.map = function(key, run, opts)
  assert((type(key) == "string"), "map key argument must be a string")
  assert((type(run) == "function"), "map run argument must be a function")
  local command
  do
    local _1_ = type(opts)
    if (_1_ == "string") then
      print("[Snap API] The third argument to snap.map is now a table, treating passed string as command, this will be deprecated")
      command = opts
    elseif (_1_ == "table") then
      command = opts.command
    elseif (_1_ == "nil") then
      command = nil
    else
      command = nil
    end
  end
  if command then
    assert((type(command) == "string"), "map command argument must be a string")
  else
  end
  local modes
  do
    local _4_ = type(opts)
    if (_4_ == "table") then
      modes = (opts.modes or "n")
    elseif (_4_ == "nil") then
      modes = "n"
    else
      modes = nil
    end
  end
  register.map(modes, key, run)
  if command then
    return register.command(command, run)
  else
    return nil
  end
end
M.maps = function(config0)
  for _, _7_ in ipairs(config0) do
    local _each_8_ = _7_
    local key = _each_8_[1]
    local run = _each_8_[2]
    local opts = _each_8_[3]
    M.map(key, run, opts)
  end
  return nil
end
M.get_producer = function(producer)
  local _9_ = type(producer)
  if (_9_ == "table") then
    return producer.default
  elseif true then
    local _ = _9_
    return producer
  else
    return nil
  end
end
M.get = function(mod)
  return require(string.format("snap.%s", mod))
end
M.sync = function(value)
  assert((type(value) == "function"), "value passed to snap.sync must be a function")
  return select(2, coroutine.yield(value))
end
M["continue_value"] = {continue = true}
M.continue = function(on_cancel)
  if on_cancel then
    assert((type(on_cancel) == "function"), "on-cancel provided to snap.continue must be a function")
  else
  end
  return coroutine.yield(M.continue_value, on_cancel)
end
M.resume = function(thread, request0, value)
  assert((type(thread) == "thread"), "thread passed to snap.resume must be a thread")
  local _, result = coroutine.resume(thread, request0, value)
  if request0.canceled() then
    return nil
  elseif (type(result) == "function") then
    return M.resume(thread, request0, M.sync(result))
  else
    return result
  end
end
M.consume = function(producer, request0)
  local producer0 = M.get_producer(producer)
  assert((type(producer0) == "function"), "producer passed to snap.consume must be a function")
  assert((type(request0) == "table"), "request passed to snap.consume must be a table")
  local reader = coroutine.create(producer0)
  local function _13_()
    if (coroutine.status(reader) == "dead") then
      reader = nil
      return nil
    else
      return M.resume(reader, request0)
    end
  end
  return _13_
end
local function _15_(_241)
  return _241.result
end
M["meta_tbl"] = {__tostring = _15_}
M.meta_result = function(result)
  local _16_ = type(result)
  if (_16_ == "string") then
    local meta_result = {result = result}
    setmetatable(meta_result, M.meta_tbl)
    return meta_result
  elseif (_16_ == "table") then
    assert((getmetatable(result) == M.meta_tbl), "result has wrong metatable")
    return result
  elseif true then
    local _ = _16_
    return assert(false, ("result passed to snap.meta_result must be a string or meta result; got: " .. type(result)))
  else
    return nil
  end
end
M.with_meta = function(result, field, value)
  assert((type(field) == "string"), "field passed to snap.with_meta must be a string")
  local meta_result = M.meta_result(result)
  do end (meta_result)[field] = value
  return meta_result
end
M.with_metas = function(result, metas)
  assert((type(metas) == "table"), "metas passed to snap.with_metas must be a table")
  local meta_result = M.meta_result(result)
  for field, value in pairs(metas) do
    meta_result[field] = value
  end
  return meta_result
end
M.has_meta = function(result, field)
  assert((type(field) == "string"), "field passed to snap.has_meta must be a string")
  return ((getmetatable(result) == M.meta_tbl) and (result[field] ~= nil))
end
M.run = function(config0)
  assert((type(config0) == "table"), "snap.run config must be a table")
  assert((type(M.get_producer(config0.producer)) == "function"), "snap.run 'producer' must be a function or a table with a default function")
  assert((type(config0.select) == "function"), "snap.run 'select' must be a function")
  if config0.multiselect then
    assert((type(config0.multiselect) == "function"), "snap.run 'multiselect' must be a function")
  else
  end
  if config0.prompt then
    assert((type(config0.prompt) == "string"), "snap.run 'prompt' must be a string")
  else
  end
  if config0.layout then
    assert((type(config0.layout) == "function"), "snap.run 'layout' must be a function")
  else
  end
  if config0.hide_views then
    assert(vim.tbl_contains({"boolean", "function"}, type(config0.hide_views)), "snap.run 'hide_views' must be a boolean or a function")
  else
  end
  if config0.views then
    assert((type(config0.views) == "table"), "snap.run 'views' must be a table")
  else
  end
  if config0.views then
    for _, view0 in ipairs(config0.views) do
      assert((type(view0) == "function"), "snap.run each view in 'views' must be a function")
    end
  else
  end
  if config0.loading then
    assert((type(config0.loading) == "function"), "snap.run 'loading' must be a function")
  else
  end
  if config0.reverse then
    assert((type(config0.reverse) == "boolean"), "snap.run 'reverse' must be a boolean")
  else
  end
  if config0.initial_filter then
    assert((type(config0.initial_filter) == "string"), "snap.run 'initial_filter' must be a string")
  else
  end
  local last_results = {}
  local last_requested_filter = ""
  local last_requested_selection = nil
  local exit = false
  local layout = (config0.layout or (M.get("layout")).centered)
  local loading = (config0.loading or M.get("loading"))
  local initial_filter = (config0.initial_filter or "")
  local original_winnr = vim.api.nvim_get_current_win()
  local prompt = string.format("%s ", (config0.prompt or "Find>"))
  local selected = {}
  local cursor_row = 1
  local hide_views = nil
  local function get_hide_views()
    if (hide_views ~= nil) then
      return hide_views
    elseif (config0.hide_views ~= nil) then
      local _27_ = type(config0.hide_views)
      if (_27_ == "function") then
        return config0.hide_views()
      elseif (_27_ == "boolean") then
        return config0.hide_views
      else
        return nil
      end
    else
      return false
    end
  end
  local input_view = nil
  local results_view = nil
  local views = {}
  local function get_selection()
    return last_results[cursor_row]
  end
  local function on_exit()
    exit = true
    last_results = {}
    selected = nil
    config0["producer"] = nil
    config0["views"] = nil
    for _, _30_ in ipairs(views) do
      local _each_31_ = _30_
      local view0 = _each_31_["view"]
      view0:delete()
    end
    results_view:delete()
    input_view:delete()
    vim.api.nvim_set_current_win(original_winnr)
    return vim.api.nvim_command("stopinsert")
  end
  local total_views
  if config0.views then
    total_views = #config0.views
  else
    total_views = 0
  end
  local function has_views()
    return ((total_views > 0) and not get_hide_views())
  end
  local function create_views()
    if has_views() then
      for index, producer in ipairs(config0.views) do
        local view0 = {view = view.create({layout = layout, index = index, ["total-views"] = total_views}), producer = producer}
        table.insert(views, view0)
      end
      return nil
    else
      return nil
    end
  end
  create_views()
  results_view = results.create({layout = layout, ["has-views"] = has_views, reverse = config0.reverse})
  local function update_cursor()
    return vim.api.nvim_win_set_cursor(results_view.winnr, {cursor_row, 0})
  end
  local update_views
  do
    local body_2_auto
    local function _34_(selection)
      for _, _35_ in ipairs(views) do
        local _each_36_ = _35_
        local _each_37_ = _each_36_["view"]
        local bufnr = _each_37_["bufnr"]
        local winnr = _each_37_["winnr"]
        local width = _each_37_["width"]
        local height = _each_37_["height"]
        local producer = _each_36_["producer"]
        local function cancel(request0)
          return (exit or (tostring(request0.selection) ~= tostring(get_selection())))
        end
        local body = {selection = selection, bufnr = bufnr, winnr = winnr, width = width, height = height}
        local request0 = request.create({body = body, cancel = cancel})
        create({producer = producer, request = request0})
      end
      return nil
    end
    body_2_auto = _34_
    local args_3_auto = nil
    local function _38_(...)
      if (args_3_auto == nil) then
        args_3_auto = {...}
        local function _39_()
          local actual_args_4_auto = args_3_auto
          args_3_auto = nil
          return body_2_auto(unpack(actual_args_4_auto))
        end
        return vim.schedule(_39_)
      else
        args_3_auto = {...}
        return nil
      end
    end
    update_views = _38_
  end
  local write_results
  do
    local body_2_auto
    local function _41_(results0, force_views)
      if not exit then
        do
          local result_size = #results0
          if (cursor_row > result_size) then
            cursor_row = math.max(1, result_size)
          else
          end
          if (result_size == 0) then
            buffer["set-lines"](results_view.bufnr, 0, -1, {})
            update_cursor()
          else
            local max = (results_view.height + cursor_row)
            local partial_results = {}
            for _, result in ipairs(results0) do
              if (max == #partial_results) then break end
              table.insert(partial_results, tostring(result))
            end
            buffer["set-lines"](results_view.bufnr, 0, -1, partial_results)
            update_cursor()
            for row in pairs(partial_results) do
              local result = (results0)[row]
              if M.has_meta(result, "positions") then
                local function _44_()
                  local _43_ = type(result.positions)
                  if (_43_ == "table") then
                    return result.positions
                  elseif (_43_ == "function") then
                    return result:positions()
                  elseif true then
                    local _ = _43_
                    return assert(false, "result positions must be a table or function")
                  else
                    return nil
                  end
                end
                buffer["add-positions-highlight"](results_view.bufnr, row, _44_())
              else
              end
              if selected[tostring(result)] then
                buffer["add-selected-highlight"](results_view.bufnr, row)
              else
              end
            end
          end
        end
        local selection = get_selection()
        if (has_views() and (force_views or (tostring(last_requested_selection) ~= tostring(selection)))) then
          last_requested_selection = selection
          for _, _49_ in ipairs(views) do
            local _each_50_ = _49_
            local view0 = _each_50_["view"]
            local bufnr = buffer.create()
            vim.api.nvim_win_set_buf(view0.winnr, bufnr)
            buffer.delete(view0.bufnr, {force = true})
            do end (view0)["bufnr"] = bufnr
          end
          if (selection ~= nil) then
            return update_views(selection)
          else
            return nil
          end
        else
          return nil
        end
      else
        return nil
      end
    end
    body_2_auto = _41_
    local args_3_auto = nil
    local function _54_(...)
      if (args_3_auto == nil) then
        args_3_auto = {...}
        local function _55_()
          local actual_args_4_auto = args_3_auto
          args_3_auto = nil
          return body_2_auto(unpack(actual_args_4_auto))
        end
        return vim.schedule(_55_)
      else
        args_3_auto = {...}
        return nil
      end
    end
    write_results = _54_
  end
  local function on_update(filter)
    last_requested_filter = filter
    local early_write = false
    local loading_count = 0
    local first_time = vim.loop.now()
    local last_time = first_time
    local results0 = {}
    local function cancel(request0)
      return (exit or (request0.filter ~= last_requested_filter))
    end
    local body = {filter = filter, height = results_view.height, winnr = original_winnr}
    local request0 = request.create({body = body, cancel = cancel})
    local config1 = {producer = M.get_producer(config0.producer), request = request0}
    local write_loading
    do
      local body_2_auto
      local function _57_()
        if not request0.canceled() then
          local loading_screen = loading(results_view.width, results_view.height, loading_count)
          return buffer["set-lines"](results_view.bufnr, 0, -1, loading_screen)
        else
          return nil
        end
      end
      body_2_auto = _57_
      local args_3_auto = nil
      local function _59_(...)
        if (args_3_auto == nil) then
          args_3_auto = {...}
          local function _60_()
            local actual_args_4_auto = args_3_auto
            args_3_auto = nil
            return body_2_auto(unpack(actual_args_4_auto))
          end
          return vim.schedule(_60_)
        else
          args_3_auto = {...}
          return nil
        end
      end
      write_loading = _59_
    end
    config1["on-end"] = function()
      if (#results0 == 0) then
        last_results = results0
        write_results(last_results)
      elseif M.has_meta(tbl.first(results0), "score") then
        local function _62_(_241, _242)
          return (_241.score > _242.score)
        end
        tbl["partial-quicksort"](results0, 1, #results0, (results_view.height + cursor_row), _62_)
        last_results = results0
        write_results(last_results)
      else
      end
      results0 = {}
      return nil
    end
    config1["on-tick"] = function()
      if not early_write then
        local current_time = vim.loop.now()
        if (((loading_count == 0) and ((current_time - first_time) > 100)) or ((current_time - last_time) > 500)) then
          loading_count = (loading_count + 1)
          last_time = current_time
          return write_loading()
        else
          return nil
        end
      else
        return nil
      end
    end
    config1["on-value"] = function(value)
      assert((type(value) == "table"), string.format("Main producer yielded a non-yieldable value: %s", value))
      if (#value > 0) then
        tbl.accumulate(results0, value)
        if not M.has_meta(tbl.first(results0), "score") then
          early_write = true
          last_results = results0
          return write_results(last_results)
        else
          return nil
        end
      else
        return nil
      end
    end
    return create(config1)
  end
  local function on_enter(type)
    local selections = vim.tbl_keys(selected)
    if (#selections == 0) then
      local selection = get_selection()
      if (selection ~= nil) then
        return vim.schedule_wrap(config0.select)(selection, original_winnr, type)
      else
        return nil
      end
    elseif config0.multiselect then
      return vim.schedule_wrap(config0.multiselect)(selections, original_winnr)
    else
      return nil
    end
  end
  local function on_select_all_toggle()
    if config0.multiselect then
      for _, value in ipairs(last_results) do
        local value0 = tostring(value)
        if selected[value0] then
          selected[value0] = nil
        else
          selected[value0] = true
        end
      end
      return write_results(last_results)
    else
      return nil
    end
  end
  local function on_select_toggle()
    if config0.multiselect then
      local selection = get_selection()
      if (selection ~= nil) then
        local value = tostring(selection)
        if selected[value] then
          selected[value] = nil
          return nil
        else
          selected[value] = true
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  end
  local function on_key_direction(next_index)
    local line_count = vim.api.nvim_buf_line_count(results_view.bufnr)
    local index = math.max(1, math.min(line_count, next_index(cursor_row)))
    cursor_row = index
    update_cursor()
    return write_results(last_results)
  end
  local function on_prev_item()
    local function _75_(_241)
      return (_241 - 1)
    end
    return on_key_direction(_75_)
  end
  local function on_next_item()
    local function _76_(_241)
      return (_241 + 1)
    end
    return on_key_direction(_76_)
  end
  local function on_prev_page()
    local function _77_(_241)
      return (_241 - results_view.height)
    end
    return on_key_direction(_77_)
  end
  local function on_next_page()
    local function _78_(_241)
      return (_241 + results_view.height)
    end
    return on_key_direction(_78_)
  end
  local function set_next_view_row(next_index)
    if has_views() then
      local _local_79_ = tbl.first(views)
      local _local_80_ = _local_79_["view"]
      local winnr = _local_80_["winnr"]
      local bufnr = _local_80_["bufnr"]
      local height = _local_80_["height"]
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      local _let_81_ = vim.api.nvim_win_get_cursor(winnr)
      local row = _let_81_[1]
      local index = math.max(1, math.min(line_count, next_index(row, height)))
      return vim.api.nvim_win_set_cursor(winnr, {index, 0})
    else
      return nil
    end
  end
  local function on_viewpageup()
    if has_views() then
      local function _83_(_241, _242)
        return (_241 - _242)
      end
      return set_next_view_row(_83_)
    else
      return nil
    end
  end
  local function on_viewpagedown()
    if has_views() then
      local function _85_(_241, _242)
        return (_241 + _242)
      end
      return set_next_view_row(_85_)
    else
      return nil
    end
  end
  local function on_next()
    if (config0.next or (config0.steps and (#config0.steps > 0))) then
      local results0 = last_results
      local next_config = {}
      for key, value in pairs(config0) do
        next_config[key] = value
      end
      local next = (config0.next or table.remove(config0.steps))
      local function _87_()
        do
          local _88_ = type(next)
          if (_88_ == "function") then
            local function _89_()
              return results0
            end
            next_config["producer"] = next(_89_)
          elseif (_88_ == "table") then
            for key, value in pairs(next.config) do
              next_config[key] = value
            end
            local _90_
            if next.format then
              _90_ = next.consumer(next.format(results0))
            else
              local function _91_()
                return results0
              end
              _90_ = next.consumer(_91_)
            end
            next_config["producer"] = _90_
          else
          end
        end
        return M.run(next_config)
      end
      return vim.schedule_wrap(_87_)()
    else
      return nil
    end
  end
  local function on_view_toggle_hide()
    if (hide_views == nil) then
      hide_views = not get_hide_views()
    else
      hide_views = not hide_views
    end
    results_view:update()
    input_view:update()
    if hide_views then
      for _, _96_ in ipairs(views) do
        local _each_97_ = _96_
        local view0 = _each_97_["view"]
        view0:delete()
      end
      views = {}
      return nil
    else
      create_views()
      vim.api.nvim_set_current_win(input_view.winnr)
      return write_results(last_results, true)
    end
  end
  input_view = input.create({reverse = config0.reverse, mappings = config0.mappings, ["has-views"] = has_views, layout = layout, prompt = prompt, ["on-enter"] = on_enter, ["on-next"] = on_next, ["on-exit"] = on_exit, ["on-prev-item"] = on_prev_item, ["on-next-item"] = on_next_item, ["on-prev-page"] = on_prev_page, ["on-next-page"] = on_next_page, ["on-viewpageup"] = on_viewpageup, ["on-viewpagedown"] = on_viewpagedown, ["on-view-toggle-hide"] = on_view_toggle_hide, ["on-select-toggle"] = on_select_toggle, ["on-select-all-toggle"] = on_select_all_toggle, ["on-update"] = on_update})
  if (initial_filter ~= "") then
    vim.api.nvim_feedkeys(initial_filter, "n", false)
  else
  end
  return nil
end
M.create = function(config0, defaults)
  assert((type(config0) == "function"), "Config must be a function")
  local function _100_()
    return M.run(tbl.merge((defaults or {}), config0()))
  end
  return _100_
end
return M
