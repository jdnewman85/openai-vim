local func = require('functional')

-- List of 20 or so common names
local names = {
  "James",      "David",     "John",     "Robert",     "Michael",
  "Charles",    "Edward",    "George",   "Joseph",     "Kenneth",
  "Christopher","Daniel",    "Paul",     "Mark",       "Donald",
  "Richard",    "Steven",    "Thomas",   "William",    "Brian",
}
local function create_starts_with_func(c)
  local upper_c = string.upper(c)


  return function(name)
    -- match, regardless of case
    local first_letter = string.sub(name, 1, 1)
    return string.upper(first_letter) == upper_c
  end
end

local name_starts_with_j = create_starts_with_func("m")



local c = names

-- filter
--[[
c = func.filter(c, name_starts_with_j)
vim.pretty_print(c)
]]--

-- map
--[[
c = func.map(c,
  function(name)
    return {name, string.sub(name, 1, 1)}
  end
)
vim.pretty_print(c)
]]--

-- reduce
--[[
all_names = func.reduce(names, "Names: ",
  function(acc, item)
    return acc .. item .. ", "
  end
)
vim.pretty_print(all_names)
]]--

