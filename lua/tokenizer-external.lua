local plenary_job = require("plenary.job")
local plenary_curl = require("plenary.curl")
local utils = require("utils")

local M = { }

--TODO don't hard code
local tokenizer_path = "/home/sci/projects/rust/bpe_tokenizer/"
local tokenizer_bin = "bpe_tokenizer"

  --TODO Use
local address = "127.0.0.1";
local port = 8080;
local server_job = nil

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
    --TODO Add an option to run the tokenizer per request
    --TODO TEMP Disabled due to orphaned server issue
    --return M.start_server()
    print("Tokenizer not running!")
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

function M.tokenizer_token_list(tokenizer, text)
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

function M.new_tokenizer(model_dir)
  --TODO Eval - Dummy virtual function to satisfy tokenizer interface
end


-- TODO Put in auto run folder
M.connect_or_start()

return M
