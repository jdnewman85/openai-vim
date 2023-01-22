function table_concat_single(t1, t2)
  for i = 1, #t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

function table_concat(t1, ...)
  local arg = {...}
  for _, t2 in ipairs(arg) do
    local t2_new = t2
    if not (type(t2_new) == "table") then
      t2_new = { t2_new }
    end
    t1 = table_concat_single(t1, t2_new)
  end
  return t1
end


local contractions = {
  "'s",
  "'t",
  "'re",
  "'m",
  "'ll",
  "'d",
}
local opt_space = " ?"
local alpha = opt_space.."%a+"
local numeric = opt_space.."%d+"
local others = opt_space.."[^%s%a%d]+"
local spaces = "%s+"

local pats = table_concat(
  contractions,
  alpha,
  numeric,
  others,
  spaces
)

function pat(s)
  local r = {}

  local i = 1
  while i <= string.len(s) do
    local matched = false

    for _, p in ipairs(pats) do
      local token = string.match(s, "^"..p, i)
      if token then
        table.insert(r, token)
        matched = true
        i = i + string.len(token)
        break
      end
    end

    if not matched then
      print("WARNING UNHANDLED STUFFS!")
      break
    end
  end


  return r
end

local test = "This is a test!\nY'all here? We'll be wait'in 'ver 'here !!!!!!!! We's all's good's?"
local t = pat(test)
vim.pretty_print(t)
