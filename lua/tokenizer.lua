local plenary_job = require"plenary.job"
local plenary_curl = require"plenary.curl"
local utils = require"utils"

local M = { }

--TODO don't hard code
local tokenizer_path = "/home/sci/projects/rust/bpe_tokenizer/"
local tokenizer_bin = "bpe_tokenizer"

  --TODO Use
local address = "127.0.0.1";
local port = 8080;
local server_job = nil

local output_window = nil
local output_buffer = nil
local highlight_namespace = nil

--TODO Highlight space characters with background or similar?
local highlight_colors = {
  "rainbowcol1",
  "rainbowcol2",
  "rainbowcol3",
  "rainbowcol4",
  "rainbowcol5",
  "rainbowcol6",
  "rainbowcol7",
}

function open_window_if_needed()
  if not output_window or not output_buffer then
    output_window, output_buffer = utils.open_floating_window()
  end

  return output_window, output_buffer
end


function get_address_if_already_running()
  --print("Checking if server is running...")
  --Use ss
  local result = utils.trim_ws(vim.fn.system("ss -lntp | grep \"bpe_tokenizer\" | awk '{print $4}'"))
  if utils.is_empty_string(result) then
    return nil
  end

  return result
end

function M.connect_or_start()
  local a = get_address_if_already_running()
  if not a then
    return M.start_server()
  end

  --print("Found server: " .. a)
  address, port = unpack(utils.string_split(a, ':'))
end

--TODO take address params?
function M.start_server()
  print("Starting tokenizer server")

  --TODO TEMP
  vim.env.PATH = vim.env.PATH .. (":" .. tokenizer_path)

  local job = plenary_job:new {
    command = tokenizer_bin,
    args = { "-s" },
    detached = false,
    cwd = tokenizer_path, --TODO Source dependent files rather than this
--[[
    on_stdout = function(s)
      vim.pretty_print("tokenizer:\t" .. s)
    end,
]]--
    on_exit = function(s)
      print("Server Stopped")
      vim.pretty_print(s)
    end,
  }

  server_job = job:start()
  return server_job
end

function M.tokenize(text)
  --print("Tokenizing: '" .. text .. "'")
  local url = "http://" .. address .. ":" .. port .. "/tokenize_new"
  local headers = {
    ["Content-Type"] = "application/json",
  }

  local response = plenary_curl.post (url, {
    body = vim.fn.json_encode({input = text}),
    headers = headers,
  }).body
  local response_decoded = vim.fn.json_decode(response)

  return response_decoded
end

function M.highlight_tokens(tokens, buffer, start_line, start_column)
  highlight_namespace = vim.api.nvim_create_namespace("TokenizerHighlights")
  local current_col = start_column
  local current_line_num = start_line
  print("Tokens: " .. #tokens)
  for i, v in ipairs(tokens) do
    local current_highlight_num = (i % #highlight_colors) + 1
    local current_highlight = highlight_colors[current_highlight_num]
    local symbol = v["symbol"]
    local symbol_len = string.len(symbol)
    vim.api.nvim_buf_add_highlight(buffer, highlight_namespace, current_highlight, current_line_num, current_col, current_col+symbol_len)
    current_col = current_col + symbol_len
    local _, num_newlines = string.gsub(symbol, "\n", "\n")
    if num_newlines > 0 then
      current_col = 0
      current_line_num = current_line_num + num_newlines
    end
  end
end

function M.highlight_tokens_extmark(tokens, buffer, start_line, start_column)
  highlight_namespace = vim.api.nvim_create_namespace("TokenizerHighlights")
  local current_col = start_column
  local current_line_num = start_line
  print("Tokens: " .. #tokens)
  local virt_text = {}
  for i, v in ipairs(tokens) do
    local current_highlight_num = (i % #highlight_colors) + 1
    local current_highlight = highlight_colors[current_highlight_num]
    local symbol = v["symbol"]
    table.insert(virt_text, {symbol, current_highlight})
  end
    vim.api.nvim_buf_set_extmark(buffer, highlight_namespace, current_line_num, current_col, {
      virt_text = virt_text,
--      virt_lines = {virt_text},
      sign_text = "AI",
--      virt_lines_leftcol = true,
      conceal = "",
    })
end

function M.tokenize_selected_text()
  local input = utils.buf_vtext()
  if not input then return end

  local buffer = 0 -- TODO
  local start_line, start_col = utils.visual_selection_range()

  local response = M.tokenize(input)
  M.highlight_tokens(response, buffer, start_line, start_col)
  --vim.pretty_print(response)
  --print("Tokens response: ".. #response)

  --TODO Place at the end line/col of selection?
  vim.api.nvim_buf_set_extmark(buffer, highlight_namespace, start_line, start_col, {
    virt_text = {{"Tokens: ".. #response, "Whitespace"}},
--    virt_lines = {virt_text},
--    sign_text = "AI",
  })
  return response
end

function M.clear_highlights(buffer)
  vim.api.nvim_buf_clear_namespace(buffer, highlight_namespace, 0, -1)
end


-- TODO Put in auto run folder
M.connect_or_start()

return M
