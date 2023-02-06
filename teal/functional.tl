local M = {}

--TODO Generators? Ranges?
--TODO self modifying methods

local type FilterPredicate = function<V>(V): boolean
function M.filter<K, V>(c: {K: V}, predicate: FilterPredicate<V>): {K: V}
  local r = {}
  for k, v in pairs(c) do
    if predicate(v) then
      r[k] = v
    end
  end
  return r
end

local type MapTransform = function<V, V2>(V): V2
function M.map<K, V, V2>(c: {K: V}, transform: MapTransform<V, V2>): {K: V2}
  local r = {}
  for k, v in pairs(c) do
    r[k] = transform(v)
  end
  return r
end

local type Reducer = function<A, V>(A, V): A
function M.reduce<K, V, A>(c: {K: V}, initial: A, reducer: Reducer<A, V>): A
  local r = initial
  for _, v in pairs(c) do
    r = reducer(r, v)
  end
  return r
end

function M.map_to_array<K, V>(c: {K: V}): {V}
  local r = {}
  for _, v in pairs(c) do
    table.insert(r, v)
  end
  return r
end

function M.reduce_map_to_array<K, V>(c: {K: V}): {V}
  return M.reduce(c, {} as {V},
    function(acc: {V}, v: V): {V}
      table.insert(acc, v)
      return acc
    end
  )
end


local type FindPredicate = function<V>(V): boolean
function M.find<K, V>(c: {K: V}, predicate: FindPredicate<V>): V
  for _, v in pairs(c) do
    if predicate(v) then
      return v
    end
  end
end

--TODO Return boolean?
function M.contains<K, V>(c: {K: V}, item: V): boolean
  for _, v in pairs(c) do
    if v == item then
      return true
    end
  end
  return false
end

function M.keys<K>(c: {K: any}): {K}
  local r = {}
  for k in pairs(c) do
    table.insert(r, k)
  end
  return r
end

-- ipairs/array versions
function M.filter_i<V>(c: {V}, predicate: FilterPredicate<V>): {V}
  local r = {}
  for _, v in ipairs(c) do
    if predicate(v) then
      table.insert(r, v)
    end
  end
  return r
end

function M.map_i<V, V2>(c: {V}, transform: MapTransform<V, V2>): {V2}
  local r = {}
  for _, v in ipairs(c) do
    table.insert(r, transform(v))
  end
  return r
end

function M.reduce_i<V, A>(c: {V}, initial: A, reducer: Reducer<A, V>): A
  local r = initial
  for _, v in ipairs(c) do
    r = reducer(r, v)
  end
  return r
end

function M.find_i<V>(c: {V}, predicate: FindPredicate<V>): V
  for _, v in ipairs(c) do
    if predicate(v) then
      return v
    end
  end
end

function M.contains_i<V>(c: {V}, item: V): boolean
  for _, v in ipairs(c) do
    if v == item then
      return true
    end
  end
  return false
end

return M
