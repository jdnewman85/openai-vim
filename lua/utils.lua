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

return M
