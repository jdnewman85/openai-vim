local openai = require('openai')


--[[
local ns_id = vim.api.nvim_create_namespace("jn-test")
print("ns_id :" .. ns_id)
local cursor_position = vim.api.nvim_win_get_cursor(0)
local cursor_row, cursor_col = unpack(cursor_position)
local opts = {
  id = 1,
--  end_line = cursor_row+2,
  virt_text = {{"test", "IncSearch"}},
  virt_text_pos = 'overlay',
}

print"HERE WE GO!"
vim.api.nvim_buf_set_extmark(0, ns_id, cursor_row, cursor_col, opts)
]]--

openai.openai_completion()

--[[
How much wood
]]--


-- Old pieces
    --vim.cmd("normal A" .. resp)
    --vim.api.nvim_buf_set_lines(popup_buf, -1, -1, false, resp)
    --vim.api.nvim_buf_set_text(popup_buf, -1, -1, false, resp)
    --local current_buf = vim.api.nvim_get_current_buf()
    --local cursor_position = vim.api.nvim_win_get_cursor(0)
    --local cursor_row, cursor_col = unpack(cursor_position)
