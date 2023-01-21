local M = {}

function M.filter(collection, predicate)
  local result = {}
  for _, v in ipairs(collection) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

function M.map(collection, transform)
  local result = {}
  for _, v in ipairs(collection) do
    table.insert(result, transform(v))
  end
  return result
end

function M.reduce(collection, initial, reducer)
  local result = initial
  for _, v in ipairs(collection) do
    result = reducer(result, v)
  end
  return result
end

function M.find(collection, predicate)
  for _, v in ipairs(collection) do
    if predicate(v) then
      return v
    end
  end
end

function M.contains(collection, item)
  for _, v in ipairs(collection) do
    if v == item then
      return v
    end
  end
  return false
end

return M
