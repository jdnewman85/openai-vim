local tokenizer = require"tokenizer"
local utils = require"utils"


local input = utils.buf_vtext()
if not input then return end

local response = tokenizer.tokenize(input)
--vim.pretty_print(response)
print("Tokens response: ".. #response)



--This is a test! A Much longer test with more text. !!!!!!!! This is coolsio! y'all like's it? Hello World!
