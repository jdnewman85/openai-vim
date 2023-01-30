local M = {}

--TODO Generators? Ranges?

local type FilterPredicate = function(any): boolean
function M.filter(collection: table, predicate: FilterPredicate): table
  local result = {}
  for k, v in pairs(collection) do
    if predicate(v) then
      result[k] = v
    end
  end
  return result
end

function M.map_to_array(collection: table): {any}
  local result = {}
  for _, v in pairs(collection) do
    table.insert(result, v)
  end
  return result
end

--TODO Evaluate whether transform should take key, and whether that should also be transformed?
local type MapTransform = function(any): any
function M.map(collection: table, transform: MapTransform): table
  local result = {}
  for k, v in pairs(collection) do
    result[k] = transform(v)
  end
  return result
end

local type Reducer = function(any, any): any
function M.reduce(collection: table, initial: any, reducer: Reducer): any
  local result = initial
  for _, v in pairs(collection) do
    result = reducer(result, v)
  end
  return result
end

local type FindPredicate = function(any): boolean
function M.find(collection: table, predicate: FindPredicate): any
  for _, v in pairs(collection) do
    if predicate(v) then
      return v
    end
  end
end

--TODO Return boolean?
function M.contains(collection: table, item: any): any
  for _, v in pairs(collection) do
    if v == item then
      return v
    end
  end
  return false
end

function M.keys(collection: table): {any}
  local result = {}
  for k in pairs(collection) do
    table.insert(result, k)
  end
  return result
end

-- ipairs/array versions
function M.filter_i(collection: {any}, predicate: function): {any}
  local result = {}
  for _, v in ipairs(collection) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

function M.map_i(collection: {any}, transform: function): {any}
  local result = {}
  for _, v in ipairs(collection) do
    table.insert(result, transform(v))
  end
  return result
end

function M.reduce_i(collection: {any}, initial: any, reducer: function): any
  local result = initial
  for _, v in ipairs(collection) do
    result = reducer(result, v)
  end
  return result
end

function M.find_i(collection: {any}, predicate: function): any
  for _, v in ipairs(collection) do
    if predicate(v) then
      return v
    end
  end
end

--TODO Return boolean?
function M.contains_i(collection: {any}, item: any): any
  for _, v in ipairs(collection) do
    if v == item then
      return v
    end
  end
  return false
end

return M
