local utf8 = require("utf8")
local utils = require("utils")

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

local pats = utils.table_concat(
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

function is_valid_bpe_char(c)
  local valid_ranges = {
    {'!', '~'},
    {'¡', '¬'},
    {'®', 'ÿ'},
  }

  for _, range in ipairs(valid_ranges) do
    local range_min, range_max = unpack(range)
    range_min = utf8.codepoint(range_min)
    range_max = utf8.codepoint(range_max)
    if c >= range_min and c <= range_max then
      return true
    end
  end

  return false
end

function bpe_char_encoder()
  local r = {}

  local n = 0 --Current re-map offset
  for i = 0,255 do
    if is_valid_bpe_char(i) then
      r[i] = utf8.char(i)
    else
      r[i] = utf8.char(n+256)
      n = n + 1
    end
  end

  return r
end

function bpe_char_decoder()
  local r = {}
  for k, v in pairs(bpe_char_encoder()) do --TODO OPT
    r[v] = k
  end
  return r
end

--[[
local test = "This is a test!\nY'all here? We'll be wait'in 'ver 'here !!!!!!!! We's all's good's?"
local t = pat(test)
vim.pretty_print(t)
]]--

--[[
print("----------------")
local btu = bpe_char_encoder()
local utb = bpe_char_decoder()

local a = btu[32]
vim.pretty_print(a)
local b = utf8.char(utb[a])
vim.pretty_print(b)
]]--
