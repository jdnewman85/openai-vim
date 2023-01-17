local utils = require('utils')
local openai_config = require('openai_config')

local M = {}

function M.request(endpoint, data, on_stdout)
  local url = "https://api.openai.com/v1/"
  local curl = require "plenary.curl"
  local auth_token = vim.env["OPENAI_APIKEY"]

  local headers = {
    ["Authorization"] = "Bearer " .. auth_token,
    ["Content-Type"] = "application/json",
  }

  local curl_opts = {
    body = vim.fn.json_encode(data),
    headers = headers,
  }

  if on_stdout then
    curl_opts["on_stdout"] = on_stdout
  end
  local job_or_response = curl.post(url .. endpoint, curl_opts)
  if data["stream"] then
    job = job_or_response
    return job
  end

  local response = job_or_response
  local response_decoded = vim.fn.json_decode(response.body)

  return response_decoded
end

--[[ TODO
function M.edits()
  local data = {
    model = "text-davinci-edit-001", --TODO
    input = utils.buf_vtext(),
    instruction = "Fix the spelling mistakes"
  }
  local response_decoded = M.request("edits", data)
--  vim.pretty_print(response_decoded)
  return response_decoded
end
]]--

function M.complete_selection()
  local txt = utils.buf_vtext()
  local data = {
    model = openai_config.get_model('completions').name,
    prompt = txt,
    max_tokens = openai_config.get_max_tokens(),
    temperature = 0,
    stream = true,
  }

  local current_buffer = 0
  local _, _, insert_row, insert_column = utils.visual_selection_range()
  --TODO Remove magic
  if insert_column == 2147483647 then -- If entire line is selected, we get "ROWMAX"
    insert_row = insert_row + 1
    insert_column = 0
  end
  local append_to_buffer_func = M._create_append_to_buffer_func(current_buffer, insert_row, insert_column)

  local response_decoded = M.request("completions", data, append_to_buffer_func)
--  vim.pretty_print(response_decoded)
  return response_decoded
end

function M._create_append_to_buffer_func(target_buffer, start_insert_row, start_insert_column)
  local insert_row = start_insert_row
  local insert_column = start_insert_column

  local fn =  function(err, data, job)
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
      local resp_array = utils.string_split(resp, "\n")

      -- Use nvim_buf_set_lines if we need to append lines,
      --  to avoid insert_row being out of bounds for nvim_buf_set_text
      --  Use nvim_buf_set_text, otherwise, so we can insert _on_ a line
      local buffer_row_length = vim.api.nvim_buf_line_count(target_buffer)
      if insert_row >= buffer_row_length then
        vim.api.nvim_buf_set_lines(target_buffer, insert_row, insert_row, true, resp_array)
      else
        vim.api.nvim_buf_set_text(target_buffer, insert_row, insert_column, insert_row, insert_column, resp_array)
      end

      local num_inserted_rows = #resp_array-1
      local response_last_line_length = string.len(resp_array[#resp_array])
      insert_row = insert_row + num_inserted_rows
      if num_inserted_rows > 0 then
        insert_column = response_last_line_length
      else
        insert_column = insert_column + response_last_line_length
      end
    end)
  end

  return fn
end



return M
