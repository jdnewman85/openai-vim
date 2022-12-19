local utils = require('utils')
local models = require('openai_models')

local M = {}

function M.open_window()
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

--[[
--TODO
If stream == true, and no callback, use function append to target location?
]]--
function M.openai_request(endpoint, data)
  local openai_url = "https://api.openai.com/v1/"
  local curl = require "plenary.curl"
  local auth_token = vim.env["OPENAI_APIKEY"]

  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. auth_token
  }

  local _, ai_buf = M.open_window()

  local job = curl.post (openai_url .. endpoint, {
    body = vim.fn.json_encode(data),
    headers = headers,
    on_stdout = M._create_append_to_buffer_func(ai_buf),
  })
  --[[
  local response = curl.post ("https://api.openai.com/v1/" .. endpoint, {
    body = vim.fn.json_encode(data),
    headers = headers,
    on_stdout = M.print_things,
  }).body
  local response_decoded = vim.fn.json_decode(response)

  return response_decoded
  ]]--
  return "TEMPORARY\n"
end

function M.openai_edits()
  local data = {
    model = "text-davinci-edit-001",
    input = utils.buf_vtext(),
    instruction = "Fix the spelling mistakes"
  }
  local response_decoded = M.openai_request("edits", data)
--  vim.pretty_print(response_decoded)
end

function M.openai_completion()
  local txt = utils.buf_vtext()
  local data = {
    model = "code-davinci-002",
    prompt = txt,
    max_tokens = 40,
    temperature = 0,
    stream = true,
  }
  local response_decoded = M.openai_request("completions", data)
--  vim.pretty_print(response_decoded)
end

function M._create_append_to_buffer_func(target_buffer)
  local f =  function(err, data, job)
    -- Trim off `Data :`
    local maybe_json = string.sub(data, 7, -1)
    if maybe_json == '[DONE]' then
      --TODO Completion hook here
      return
    end

    local is_empty = string.sub(maybe_json, 1, -1) == ''
    if is_empty then
      --    print("Skipping empty string '" .. maybe_json .. "'")
      return
    end

    vim.schedule(function()
      local d = vim.fn.json_decode(maybe_json)
      local resp = d.choices[1].text
      local end_of_buf = utils.buf_get_end_pos(target_buffer)
      local insert_row = end_of_buf[1]-1
      --TODO Determine why row needs -1, but col doesn't
      --Maybe related to neovim.io/doc/user/api.html api-indexing exceptions
      --local insert_col = end_of_buf[2]-1
      local insert_col = end_of_buf[2]

      local resp_array = utils.string_split(resp, "\n")
      vim.api.nvim_buf_set_text(target_buffer, insert_row, insert_col, insert_row, insert_col, resp_array)
    end)
  end

  return f
end



return M
