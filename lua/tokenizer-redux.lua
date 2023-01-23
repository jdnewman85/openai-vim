local utf8 = require("utf8")
local utils = require("utils")
--local func = require("functional") --TODO use

local contractions = {
  "'s",
  "'t",
  "'re",
  "'m",
  "'ll",
  "'d",
}
local opt_space = " ?"
local alpha = opt_space.."%a+"
local numeric = opt_space.."%d+"
local others = opt_space.."[^%s%a%d]+"
local spaces = "%s+"

local pats = utils.table_concat(
  contractions,
  alpha,
  numeric,
  others,
  spaces
)

function pat(s)
  local r = {}

  local i = 1
  while i <= string.len(s) do
    local matched = false

    for _, p in ipairs(pats) do
      local token = string.match(s, "^"..p, i)
      if token then
        table.insert(r, token)
        matched = true
        i = i + string.len(token)
        break
      end
    end

    if not matched then
      print("WARNING UNHANDLED STUFFS!")
      break
    end
  end

  return r
end

function is_valid_bpe_char(c)
  local valid_ranges = {
    {'!', '~'},
    {'¡', '¬'},
    {'®', 'ÿ'},
  }

  for _, range in ipairs(valid_ranges) do
    local range_min, range_max = unpack(range)
    range_min = utf8.codepoint(range_min)
    range_max = utf8.codepoint(range_max)
    if c >= range_min and c <= range_max then
      return true
    end
  end

  return false
end

function bpe_char_encoder()
  local r = {}

  local n = 0 --Current re-map offset
  for i = 0,255 do
    if is_valid_bpe_char(i) then
      r[i] = utf8.char(i)
    else
      r[i] = utf8.char(n+256)
      n = n + 1
    end
  end

  return r
end

function bpe_char_decoder() -- TODO OPT
  return utils.swap_kv(bpe_char_encoder())
end

function bpe_token_encoder(filename)
  local file = vim.fn.join(vim.fn.readfile(filename))
  return vim.json.decode(file)
end

function bpe_token_decoder(filename) --TODO OPT
  return utils.swap_kv(bpe_token_encoder(filename))
end

function bpe_ranks(filename)
  local file_lines = vim.fn.readfile(filename)
  --First line is a comment
  table.remove(file_lines, 1) --OPT? Expensive

  local bpe_ranks = {}
  for rank, bpe_pair in ipairs(file_lines) do
    bpe_ranks[bpe_pair] = rank
  end

  return bpe_ranks
end


function new_tokenizer(model_dir)
  local r = {}

  r.byte_encoder = bpe_char_encoder()
  r.byte_decoder = bpe_char_decoder()
  r.token_encoder = bpe_token_encoder(model_dir.."/encoder.json")
  r.token_decoder = bpe_token_decoder(model_dir.."/encoder.json")
  r.bpe_ranks = bpe_ranks(model_dir.."/vocab.bpe")

  return r
end

function consecutive_pairs(word)
  local word_length = #word
  if word_length <= 1 then
    return word
  end

  local r = {}
  for i = 1,#word-1 do
    table.insert(r, {word[i], word[i+1]})
  end
  return r
end

function bpe_word_from_string(token)
  local r = {}
  for char in string.gmatch(token, '.') do
    table.insert(r, char)
  end
  return r
end

function tokenizer_bpe(tokenizer, token) --TODO OOP
  local word = bpe_word_from_string(token)

  while true do
    local symbol_pairs = consecutive_pairs(word)
    local min_bigram = nil
    local min_rank = math.huge

    for _, pair in ipairs(symbol_pairs) do
      local bigram_key = table.concat(pair, " ")
      local rank = tokenizer.bpe_ranks[bigram_key]
      if rank and rank < min_rank then
        min_bigram = pair
        min_rank = rank
      end
    end
    if not min_bigram then
      return word
    end

    local next_word = {}
    local i = 1
    while i <= #word do
      if i ~= #word and min_bigram[1] == word[i] and min_bigram[2] == word[i+1] then
        table.insert(next_word, table.concat(min_bigram))
        i = i + 1
      else
        table.insert(next_word, word[i])
      end
      i = i + 1
    end

    word = next_word
    if #word == 1 then
      return word
    end
  end
end

local tokenizer = new_tokenizer("/home/sci")
local test_bpe = tokenizer_bpe(tokenizer, "!!!!!!!!")
vim.pretty_print(test_bpe)
