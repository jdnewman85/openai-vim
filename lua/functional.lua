local M = {}

-- filter(collection, predicate)
function M.filter(collection, predicate)
    local result = {}
    for _, v in ipairs(collection) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

-- map(collection, transform)
function M.map(collection, transform)
    local result = {}
    for _, v in ipairs(collection) do
        table.insert(result, transform(v))
    end
    return result
end

-- reduce(collection, initial, reducer)
function M.reduce(collection, initial, reducer)
    local result = initial
    for _, v in ipairs(collection) do
        result = reducer(result, v)
    end
    return result
end

return M
