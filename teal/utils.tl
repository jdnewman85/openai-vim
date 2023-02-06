--TODO Tidy and eval
local M = {}

function M.get_vsel(): table
  local bufnr = vim.api.nvim_win_get_buf(0)
  local start = vim.fn.getpos('v') as {number, number, number, number} -- [bufnum, lnum, col, off] --TODO Correct/PR vim.fn.getpos in teal-types
  local _end = vim.fn.getpos('.') as {number, number, number, number} -- [bufnum, lnum, col, off]
  return {
    bufnr = bufnr,
    mode = vim.fn.mode(),
    pos = { start[2], start[3], _end[2], _end[3] },
  }
end

function M.buf_text(): string
  local bufnr = vim.api.nvim_win_get_buf(0)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(bufnr), true)
  local text = ''
  for _, line in ipairs(lines) do
    text = text .. line .. '\n'
  end
  return text
end

function M.buf_vtext(): string
  local a_orig = vim.fn.getreg('a')
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' then
    vim.cmd[[normal! gv]]
  end
  vim.cmd[[normal! "aygv]]
  local text = vim.fn.getreg('a') as string --TODO Correct/PR vim.fn.getreg in teal-types
  vim.fn.setreg('a', a_orig)
  return text
end

function M.buf_get_end_pos(buf: integer): {number, number}
  local num_rows = vim.api.nvim_buf_line_count(buf)
  local strict_indexing = true
  local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, strict_indexing)[1]
  local last_line_length = string.len(last_line)
  return {num_rows, last_line_length}
end


function M.trim_ws(s: string): string
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function M.is_empty_string(s: string): boolean
  return not s or (s == "")
end

function M.print_things(_err: table, data: table, _job: table)
  print(data)
end

function M.string_split(s: string, delimiter: string): {string}
  local result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

function M.string_join(strs: {string}, delimiter: string): string
  local r = ""
  for _, s in ipairs(strs) do
    r = r..s..delimiter
  end
  --Trim last delimiter
  local delimiter_length = string.len(delimiter)
  local r_length = string.len(r)
  r = string.sub(r, 1, r_length-delimiter_length)
  return r
end

function M.open_floating_window(): integer, integer
  local new_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_option(new_buf, 'bufhidden', 'wipe')

  local term_width = vim.api.nvim_get_option('columns') as number
  local term_height = vim.api.nvim_get_option('lines') as number

  local win_width = math.ceil(term_width * 0.7)
  local win_height = math.ceil(term_height * 0.5 - 4)

  local row = math.ceil((term_height - win_height) / 2 - 1)
  local col = math.ceil((term_width - win_width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  local focus_new_window = false
  local new_win = vim.api.nvim_open_win(new_buf, focus_new_window, opts)

  return new_win, new_buf
end

--TODO Attribute
--https://github.com/theHamsta/nvim-treesitter/blob/a5f2970d7af947c066fb65aef2220335008242b7/lua/nvim-treesitter/incremental_selection.lua#L22-L30
--- Get a ts compatible range of the current visual selection.
--
-- The range of ts nodes start with 0 and the ending range is exclusive.
function M.visual_selection_range(): integer, integer, integer, integer
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<") as {integer, integer, integer, integer})
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>") as {integer, integer, integer, integer})
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow - 1, cscol - 1, cerow - 1, cecol
  else
    return cerow - 1, cecol - 1, csrow - 1, cscol
  end
end

--TODO Rename
function M.combine_tables(t1: {any}, t2: {any}): {any}
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end

--TODO Rename
function M.table_concat(t1: {any}, ...: {any}): {any}
  local args = {...}
  for _, a in ipairs(args) do
    local t2 = a
    -- Handle non-tables by wrapping them
    if not (type(t2) == "table") then
      t2 = { t2 }
    end

    -- Actual concat
    for i = 1, #t2 do
      t1[#t1+1] = t2[i]
    end
  end
  return t1
end

function M.swap_kv<K, V>(t: {K: V}): {V: K}
  local r = {}
  for k,v in pairs(t) do
    r[v] = k
  end
  return r
end

--[[
local p = require("jit.p")
function M.prof_start(filename)
  p.start("20,s,m0,G", filename)
end
function M.prof_stop()
  p.stop()
end
]]


return M
