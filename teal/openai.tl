local utils = require('utils')
local openai_config = require('openai_config')

local M = {}

function M.request(endpoint: string, data: table, on_stdout: function): any
  local url = "https://api.openai.com/v1/"
  local curl = require('plenary.curl')
  local auth_token = vim.env["OPENAI_APIKEY"] as string --TODO correct and PR teal-types

  local headers = {
    ["Authorization"] = "Bearer " .. auth_token,
    ["Content-Type"] = "application/json",
  }

  local curl_opts: {string: any} = {
    body = vim.fn.json_encode(data),
    headers = headers,
  }

  if on_stdout then
    curl_opts["on_stdout"] = on_stdout
  end
  local job_or_response = curl.post(url .. endpoint, curl_opts)
  --if data["stream"] then
  if on_stdout then
    local job = job_or_response
    return job
  end

  local response = job_or_response
  local response_decoded = vim.fn.json_decode(response.body)

  return response_decoded
end

local type ThenFn = function(string): any
local function request_edit_instruction(then_fn: ThenFn)
  vim.ui.input(
    {
      prompt = "Instruction:",
--!      default = "",
--!      kind = "max_tokens", --TODO Define a kind for this? OR change max_tokens to `centered`?
      --telescope = require("telescope.themes").get_ivy(),
    },
    then_fn
  )
end

function M.buffer_edit(append)
  request_edit_instruction(function(instruction: string): any
    local current_buffer = 0
    local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, true) as {string} --TODO correct and PR teal-types
    local input = utils.string_join(lines, "\n")
    local data: table = {
      model = openai_config:get_current_model('edits').name,
      input = input,
      instruction = instruction,
    }
    --TODO Handle err
    local job = M.request("edits", data, function(_err: any, dat: table, _job: any)
      vim.schedule(function()
        local obj = vim.fn.json_decode(dat) as {string: any} --TODO Define and use response record
        local choices = obj.choices as {table}
        local first_choice = choices[1] as table
        local response = first_choice.text as string
        local split_response = utils.string_split(response, "\n")
        --vim.pretty_print(response)
        local start_line = 0
        if append then
          start_line = -1
        end
        vim.api.nvim_buf_set_lines(current_buffer, start_line, -1, true, split_response)
        print("Finished Edits")
      end)
    end)
    --vim.pretty_print(response_decoded)
    return job
  end)
end

function M.selection_edit() --TODO Factor common portions with buffer_edit out
  request_edit_instruction(function(instruction: string): any
    local current_buffer = 0
    local select_start_row, select_start_column, select_end_row, select_end_column = utils.visual_selection_range()
    if select_end_column == 2147483647 then -- If entire line is selected, we get "ROWMAX"
      local end_line = vim.api.nvim_buf_get_lines(current_buffer, select_end_row, select_end_row+1, true)[1]
      select_end_column = string.len(end_line)
    end
    local buf_text = vim.api.nvim_buf_get_text(current_buffer, select_start_row, select_start_column, select_end_row, select_end_column, {})
    local input = utils.string_join(buf_text, "\n")
    local data: table = {
      model = openai_config:get_current_model('edits').name,
      input = input,
      instruction = instruction,
    }
    --TODO Handle err
    local job = M.request("edits", data, function(_err: any, dat: table, _job: any) --TODO Better types
      vim.schedule(function()
        local obj = vim.fn.json_decode(dat) as {string: any} --TODO Define and use response record
        local choices = obj.choices as {table}
        local first_choice = choices[1] as table
        local response = first_choice.text as string
        local split_response = utils.string_split(response, "\n")
        --vim.pretty_print(response)
        table.remove(split_response) -- HACK - Edit seems to always append a newline?
        vim.api.nvim_buf_set_text(current_buffer, select_start_row, select_start_column, select_end_row, select_end_column, {response})
        print("Finished Edits")
      end)
    end)
    --vim.pretty_print(response_decoded)
    return job
  end)
end

function M._create_append_to_buffer_func(target_buffer: integer, start_insert_row: integer, start_insert_column: integer): function
  local insert_row = start_insert_row
  local insert_column = start_insert_column

  if insert_column == 2147483647 then -- If entire line is selected, we get "ROWMAX"
    insert_row = insert_row + 1
    insert_column = 0
  end

  local fn =  function(_err: any, data: string, _job: any) --TODO Better types
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
      local d = vim.fn.json_decode(maybe_json) as table --TODO Define/use record
      local choices = d.choices as {table}
      local choice = choices[1] as table
      local resp = choice.text as string
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

function M.buffer_context_insert_at_cursor(stops: {string}): any --TODO Rename --TODO TEMP stop parameter
  local current_window = 0
  local current_buffer = 0
  local cursor_row, cursor_column = unpack(vim.api.nvim_win_get_cursor(current_window))
  local buffer_num_lines = vim.api.nvim_buf_line_count(current_buffer)
  local last_line = vim.api.nvim_buf_get_lines(current_buffer, -2, -1, true)[1]
  local last_line_length = string.len(last_line)

  -- HACK?
  cursor_row = cursor_row - 1

  -- Get prefix/prompt - everything before cursor
  local prompt_lines = vim.api.nvim_buf_get_text(current_buffer, 0, 0, cursor_row, cursor_column, {})
  local prompt = utils.string_join(prompt_lines, "\n")
  local suffix_lines = vim.api.nvim_buf_get_text(current_buffer, cursor_row, cursor_column, buffer_num_lines-1, last_line_length, {})
  local suffix = utils.string_join(suffix_lines, "\n")
  local data: table = {
    model = openai_config:get_current_model('completions').name,
    prompt = prompt,
    suffix = suffix,
    max_tokens = openai_config:get_max_tokens(),
    temperature = 0,
    stream = true,
    stop = stops,
  }

  local append_to_buffer_func = M._create_append_to_buffer_func(current_buffer, cursor_row, cursor_column)

  print("-------------------------------")
  vim.pretty_print(data)
  local response_decoded = M.request("completions", data, append_to_buffer_func)
--  vim.pretty_print(response_decoded)
  return response_decoded
end

function M.complete_selection(): any
  local txt = utils.buf_vtext()
  local data: table = {
    model = openai_config:get_current_model('completions').name,
    prompt = txt,
    max_tokens = openai_config:get_max_tokens(),
    temperature = 0,
    stream = true,
  }

  local current_buffer = 0
  local _, _, insert_row, insert_column = utils.visual_selection_range()
  local append_to_buffer_func = M._create_append_to_buffer_func(current_buffer, insert_row, insert_column)

  local response_decoded = M.request("completions", data, append_to_buffer_func)
--  vim.pretty_print(response_decoded)
  return response_decoded
end


function M.buffer_context_complete_line(): any
  local stops = {
    "\n"
  }
  return M.buffer_context_insert_at_cursor(stops)
end


return M
