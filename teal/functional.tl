--TODO Generators? Ranges?
--TODO self modifying methods
local type FilterPredicate = function<V>(V): boolean
local type MapTransform = function<V, V2>(V): V2
local type Reducer = function<A, V>(A, V): A
local type FindPredicate = function<V>(V): boolean

local record Func
  filter: function<K, V>(c: {K: V}, predicate: FilterPredicate<V>): {K: V}
  filter_i: function<V>(c: {V}, predicate: FilterPredicate<V>): {V}
  map: function<K, V, V2>(c: {K: V}, transform: MapTransform<V, V2>): {K: V2}
  map_i: function<V, V2>(c: {V}, transform: MapTransform<V, V2>): {V2}
  reduce: function<K, V, A>(c: {K: V}, initial: A, reducer: Reducer<A, V>): A
  reduce_i: function<V, A>(c: {V}, initial: A, reducer: Reducer<A, V>): A
  map_to_array: function<K, V>(c: {K: V}): {V}
  reduce_map_to_array: function<K, V>(c: {K: V}): {V}
  find: function<K, V>(c: {K: V}, predicate: FindPredicate<V>): V
  find_i: function<V>(c: {V}, predicate: FindPredicate<V>): V
  contains: function<K, V>(c: {K: V}, item: V): boolean
  contains_i: function<V>(c: {V}, item: V): boolean
  keys: function<K>(c: {K: any}): {K}
end

function Func.filter<K, V>(c: {K: V}, predicate: FilterPredicate<V>): {K: V}
  local r = {}
  for k, v in pairs(c) do
    if predicate(v) then
      r[k] = v
    end
  end
  setmetatable(r, getmetatable(c))
  return r
end
function Func.filter_i<V>(c: {V}, predicate: FilterPredicate<V>): {V}
  local r = {}
  for _, v in ipairs(c) do
    if predicate(v) then
      table.insert(r, v)
    end
  end
  setmetatable(r, getmetatable(c))
  return r
end

function Func.map<K, V, V2>(c: {K: V}, transform: MapTransform<V, V2>): {K: V2}
  local r = {}
  for k, v in pairs(c) do
    r[k] = transform(v)
  end
  setmetatable(r, getmetatable(c))
  return r
end
function Func.map_i<V, V2>(c: {V}, transform: MapTransform<V, V2>): {V2}
  local r = {}
  for _, v in ipairs(c) do
    table.insert(r, transform(v))
  end
  setmetatable(r, getmetatable(c))
  return r
end

function Func.reduce<K, V, A>(c: {K: V}, initial: A, reducer: Reducer<A, V>): A
  local r = initial
  for _, v in pairs(c) do
    r = reducer(r, v)
  end
  setmetatable(r, getmetatable(initial)) --TODO Needed?
  return r
end
function Func.reduce_i<V, A>(c: {V}, initial: A, reducer: Reducer<A, V>): A
  local r = initial
  for _, v in ipairs(c) do
    r = reducer(r, v)
  end
  setmetatable(r, getmetatable(initial))
  return r
end

function Func.find<K, V>(c: {K: V}, predicate: FindPredicate<V>): V
  for _, v in pairs(c) do
    if predicate(v) then
      return v
    end
  end
end
function Func.find_i<V>(c: {V}, predicate: FindPredicate<V>): V
  for _, v in ipairs(c) do
    if predicate(v) then
      return v
    end
  end
end

function Func.contains<K, V>(c: {K: V}, item: V): boolean
  for _, v in pairs(c) do
    if v == item then
      return true
    end
  end
  return false
end
function Func.contains_i<V>(c: {V}, item: V): boolean
  for _, v in ipairs(c) do
    if v == item then
      return true
    end
  end
  return false
end

function Func.keys<K>(c: {K: any}): {K}
  local r = {}
  for k in pairs(c) do
    table.insert(r, k)
  end
  return r
end

return Func
