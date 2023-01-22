local M = {}

function M.get_vsel()
  local bufnr = vim.api.nvim_win_get_buf(0)
  local start = vim.fn.getpos('v') -- [bufnum, lnum, col, off]
  local _end = vim.fn.getpos('.') -- [bufnum, lnum, col, off]
  return {
    bufnr = bufnr,
    mode = vim.fn.mode(),
    pos = { start[2], start[3], _end[2], _end[3] },
  }
end

function M.set_vsel(vsel)
  if vsel.mode ~= 'v' and vsel.mode ~= 'V' then
    return
  end
  vim.fn.setpos(".", { vsel.bufnr, vsel.pos[1], vsel.pos[2] })
  vim.cmd('normal!' .. vsel.mode)
  vim.fn.setpos(".", { vsel.bufnr, vsel.pos[3], vsel.pos[4] })
end

function M.buf_text()
  local bufnr = vim.api.nvim_win_get_buf(0)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(bufnr), true)
  local text = ''
  for i, line in ipairs(lines) do
    text = text .. line .. '\n'
  end
  return text
end

function M.buf_vtext()
  local a_orig = vim.fn.getreg('a')
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' then
    vim.cmd[[normal! gv]]
  end
  vim.cmd[[normal! "aygv]]
  local text = vim.fn.getreg('a')
  vim.fn.setreg('a', a_orig)
  return text
end

function M.buf_get_end_pos(buf)
  local num_rows = vim.api.nvim_buf_line_count(buf)
  local strict_indexing = true
  local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, strict_indexing)[1]
  local last_line_length = string.len(last_line)
  return {num_rows, last_line_length}
end


function M.trim_ws(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function M.is_empty_string(s)
  return not s or (s == "")
end

function M.print_things(err, data, job)
  print(data)
end

function M.string_split(s, delimiter)
  result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

function M.string_join(s, delimiter)
  r = ""
  for _, str in ipairs(s) do
    r = r..str..delimiter
  end
  --Trim last delimiter
  local delimiter_length = string.len(delimiter)
  local r_length = string.len(r)
  r = string.sub(r, 1, r_length-delimiter_length)
  return r
end

function M.open_floating_window()
  new_buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_option(new_buf, 'bufhidden', 'wipe')

  local term_width = vim.api.nvim_get_option('columns')
  local term_height = vim.api.nvim_get_option('lines')

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
function M.visual_selection_range()
  local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
  local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  if csrow < cerow or (csrow == cerow and cscol <= cecol) then
    return csrow - 1, cscol - 1, cerow - 1, cecol
  else
    return cerow - 1, cecol - 1, csrow - 1, cscol
  end
end

function M.combine_tables(t1, t2)
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end

function M.table_concat(t1, ...)
  local args = {...}
  for _, arg in ipairs(args) do
    local t2 = arg
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

return M
