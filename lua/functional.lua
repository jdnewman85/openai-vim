local M = {}

--TODO Generators? Ranges?

function M.filter(collection, predicate)
  local result = {}
  for _, v in pairs(collection) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

function M.map(collection, transform)
  local result = {}
  for _, v in pairs(collection) do
    table.insert(result, transform(v))
  end
  return result
end

function M.reduce(collection, initial, reducer)
  local result = initial
  for _, v in pairs(collection) do
    result = reducer(result, v)
  end
  return result
end

function M.find(collection, predicate)
  for _, v in pairs(collection) do
    if predicate(v) then
      return v
    end
  end
end

function M.contains(collection, item)
  for _, v in pairs(collection) do
    if v == item then
      return v --TODO Maybe it would be more useful to return the key?
    end
  end
  return false
end

function M.keys(collection)
  local result = {}
  for k in pairs(collection) do
    table.insert(result, k)
  end
  return result
end

-- ipairs/array versions
function M.filter_i(collection, predicate)
  local result = {}
  for _, v in ipairs(collection) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

function M.map_i(collection, transform)
  local result = {}
  for _, v in ipairs(collection) do
    table.insert(result, transform(v))
  end
  return result
end

function M.reduce_i(collection, initial, reducer)
  local result = initial
  for _, v in ipairs(collection) do
    result = reducer(result, v)
  end
  return result
end

function M.find_i(collection, predicate)
  for _, v in ipairs(collection) do
    if predicate(v) then
      return v
    end
  end
end

function M.contains_i(collection, item)
  for _, v in ipairs(collection) do
    if v == item then
      return v --TODO Maybe it would be more useful to return the key?
    end
  end
  return false
end

return M
