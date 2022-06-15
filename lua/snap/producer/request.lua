local M = {}
M.create = function(config)
  assert((type(config.body) == "table"), "body must be a table")
  assert((type(config.cancel) == "function"), "cancel must be a function")
  local request = {["is-canceled"] = false}
  for key, value in pairs(config.body) do
    request[key] = value
  end
  request.cancel = function()
    request["is-canceled"] = true
    return nil
  end
  request.canceled = function()
    return (request["is-canceled"] or config.cancel(request))
  end
  return request
end
return M
