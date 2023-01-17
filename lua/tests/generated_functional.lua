-- Some random functional stuff written using the completion/insert and to end of line

-- List of 20 or so common names
local names = { "James", "David", "John", "Robert", "Michael", "William", "Richard", "Charles", "Joseph", "Thomas", "Christopher", "Daniel", "Paul", "Mark", "Donald", "George", "Kenneth", "Steven", "Edward", "Brian" }

-- filter(collection, predicate)
local function filter(collection, predicate)
    local result = {}
    for _, v in ipairs(collection) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

-- map(collection, transform)
local function map(collection, transform)
    local result = {}
    for _, v in ipairs(collection) do
        table.insert(result, transform(v))
    end
    return result
end

-- reduce(collection, initial, reducer)
local function reduce(collection, initial, reducer)
    local result = initial
    for _, v in ipairs(collection) do
        result = reducer(result, v)
    end
    return result
end

-- Example usage of filter by defininig and using name_starts_with_j predicate
local function name_starts_with_j(name)
    return string.sub(name, 1, 1) == "J"
end

local j_names = filter(names, name_starts_with_j)

vim.pretty_print(j_names)
