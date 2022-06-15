local M = {}
M.accumulate = function(tbl, vals)
  if (vals ~= nil) then
    for _, value in ipairs(vals) do
      if (tostring(value) ~= "") then
        table.insert(tbl, value)
      else
      end
    end
    return nil
  else
    return nil
  end
end
M.merge = function(tbl1, tbl2)
  local result = {}
  for key, val in pairs(tbl1) do
    result[key] = val
  end
  for key, val in pairs(tbl2) do
    result[key] = val
  end
  return result
end
M.concat = function(tbl_a, tbl_b)
  local tbl = {}
  for _, value in ipairs(tbl_a) do
    table.insert(tbl, value)
  end
  for _, value in ipairs(tbl_b) do
    table.insert(tbl, value)
  end
  return tbl
end
M.take = function(tbl, num)
  local partial_tbl = {}
  for _, value in ipairs(tbl) do
    if (num == #partial_tbl) then break end
    table.insert(partial_tbl, value)
  end
  return partial_tbl
end
M.sum = function(tbl)
  local count = 0
  for _, val in ipairs(tbl) do
    count = (count + val)
  end
  return count
end
M.first = function(tbl)
  if tbl then
    return tbl[1]
  else
    return nil
  end
end
M.allocate = function(total, divisor)
  local remainder = total
  local parts = {}
  local part = math.floor((total / divisor))
  for i = 1, divisor do
    if (i == divisor) then
      table.insert(parts, remainder)
    else
      table.insert(parts, part)
      remainder = (remainder - part)
    end
  end
  return parts
end
local function partition(tbl, p, r, comp)
  local x = tbl[r]
  local i = (p - 1)
  for j = p, (r - 1), 1 do
    if comp(tbl[j], x) then
      i = (i + 1)
      local temp = tbl[i]
      tbl[i] = tbl[j]
      tbl[j] = temp
    else
    end
  end
  local temp = tbl[(i + 1)]
  tbl[(i + 1)] = tbl[r]
  tbl[r] = temp
  return (i + 1)
end
M["partial-quicksort"] = function(tbl, p, r, m, comp)
  if (p < r) then
    local q = partition(tbl, p, r, comp)
    M["partial-quicksort"](tbl, p, (q - 1), m, comp)
    if (p < (m - 1)) then
      return M["partial-quicksort"](tbl, (q + 1), r, m, comp)
    else
      return nil
    end
  else
    return nil
  end
end
return M
