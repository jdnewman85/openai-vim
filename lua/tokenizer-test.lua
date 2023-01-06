local tokenizer = require"tokenizer"
local utils = require"utils"


local input = utils.buf_vtext()
if not input then return end

local response = tokenizer.tokenize(input)
vim.pretty_print(response)



--This is a test!
