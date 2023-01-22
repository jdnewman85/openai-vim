local utf8 = require("utf8")

local v = utf8.codepoint(" ")+256
vim.pretty_print(v)

local offset_space = utf8.char(v)
vim.pretty_print(offset_space)

local back = utf8.codepoint(offset_space)
vim.pretty_print(back)

local vs = {}
for _, c in utf8.codes(" This") do
  local c = utf8.codepoint(c)
  if c == 32 then
    c = c +256
  end
  table.insert(vs, c)
end
vim.pretty_print(vs)

local o = utf8.char(unpack(vs))
vim.pretty_print(o)
