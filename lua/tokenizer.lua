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
local highlight_group = nil
local highlight_namespace = nil

function open_window()
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

function open_window_if_needed()
  if not output_window or not output_buffer then
    output_window, output_buffer = open_window()
  end

  return output_window, output_buffer
end


function get_address_if_already_running()
  print("Checking if server is running...")
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

  print("Found server: " .. a)
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
  print("Tokenizing: '" .. text .. "'")
  local url = "http://" .. address .. ":" .. port .. "/tokenize_new"
  local headers = {
    ["Content-Type"] = "application/json",
  }

  local response = plenary_curl.post (url, {
    body = vim.fn.json_encode({input = text}),
    headers = headers,
  }).body
  local response_decoded = vim.fn.json_decode(response)

  local win, buf = open_window_if_needed()
  local split_text = utils.string_split(text, "\n")
  vim.api.nvim_buf_set_lines(buf, -1, -1, true, split_text)

  highlight_namespace = vim.api.nvim_create_namespace("TODO")
  highlight_group = highlight_group or vim.api.nvim_buf_add_highlight(buf, highlight_namespace, "String", 0, 0, -1)

  return response_decoded
end

-- TODO Put in auto run folder
M.connect_or_start()

return M
