local utils = require("utils")

-- TODO Allow user config to choose
local tokenizer = require("tokenizer-internal")
--local tokenizer = require("tokenizer-external")

-- TODO Put in auto run folder
local _tokenizer = tokenizer.new_tokenizer("/home/sci")

local M = { }

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

function M.tokenize(text)
  --print("Tokenizing: '" .. text .. "'")
  return tokenizer.tokenizer_token_list(_tokenizer, text) --TODO OMG....
end

function M.highlight_tokens(tokens, buffer, start_line, start_column)
  highlight_namespace = vim.api.nvim_create_namespace("TokenizerHighlights")
  local current_col = start_column
  local current_line_num = start_line
  --print("Tokens: " .. #tokens)
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
  })
  return response
end

function M.clear_highlights(buffer)
  vim.api.nvim_buf_clear_namespace(buffer, highlight_namespace, 0, -1)
end

return M
