local M = {}

--TODO Generators? Ranges?

local type FilterPredicate = function<V>(V): boolean
function M.filter<K, V>(collection: {K: V}, predicate: FilterPredicate<V>): {K: V}
  local result = {}
  for k, v in pairs(collection) do
    if predicate(v) then
      result[k] = v
    end
  end
  return result
end

function M.map_to_array<K, V>(collection: {K: V}): {V}
  local result = {}
  for _, v in pairs(collection) do
    table.insert(result, v)
  end
  return result
end

--TODO Evaluate whether transform should take key, and whether that should also be transformed?
local type MapTransform = function<V, V2>(V): V2
function M.map<K, V, V2>(collection: {K: V}, transform: MapTransform<V, V2>): {K: V2}
  local result = {}
  for k, v in pairs(collection) do
    result[k] = transform(v)
  end
  return result
end

local type Reducer = function<A, V>(A, V): A
function M.reduce<K, V, A>(collection: {K: V}, initial: A, reducer: Reducer<A, V>): A
  local result = initial
  for _, v in pairs(collection) do
    result = reducer(result, v)
  end
  return result
end

local type FindPredicate = function<V>(V): boolean
function M.find<K, V>(collection: {K: V}, predicate: FindPredicate<V>): V
  for _, v in pairs(collection) do
    if predicate(v) then
      return v
    end
  end
end

--TODO Return boolean?
function M.contains<K, V>(collection: {K: V}, item: V): boolean
  for _, v in pairs(collection) do
    if v == item then
      return true
    end
  end
  return false
end

function M.keys<K>(collection: {K: any}): {K}
  local result = {}
  for k in pairs(collection) do
    table.insert(result, k)
  end
  return result
end

-- ipairs/array versions
function M.filter_i<V>(collection: {V}, predicate: FilterPredicate<V>): {V}
  local result = {}
  for _, v in ipairs(collection) do
    if predicate(v) then
      table.insert(result, v)
    end
  end
  return result
end

function M.map_i<V, V2>(collection: {V}, transform: MapTransform<V, V2>): {V2}
  local result = {}
  for _, v in ipairs(collection) do
    table.insert(result, transform(v))
  end
  return result
end

function M.reduce_i<V, A>(collection: {V}, initial: A, reducer: Reducer<A, V>): A
  local result = initial
  for _, v in ipairs(collection) do
    result = reducer(result, v)
  end
  return result
end

function M.find_i<V>(collection: {V}, predicate: FindPredicate<V>): V
  for _, v in ipairs(collection) do
    if predicate(v) then
      return v
    end
  end
end

--TODO Return boolean?
function M.contains_i<V>(collection: {V}, item: V): boolean
  for _, v in ipairs(collection) do
    if v == item then
      return true
    end
  end
  return false
end

return M
