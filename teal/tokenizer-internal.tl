local utf8_ = require("utf8") --TODO Make teal issue - Don't bring in compat stdlib if turned off
local utils = require("utils")
--local func = require("functional") --TODO use? Eval performance? Iterators?

local contractions = {
  "'s",
  "'t",
  "'re",
  "'m",
  "'ll",
  "'d",
}
local opt_space = " ?"
local opt_space_alpha = opt_space.."%a+"
local opt_space_numeric = opt_space.."%d+"
local opt_space_others = opt_space.."[^%s%a%d]+"
local spaces = "%s+"

local pats = {
  unpack(contractions),
  opt_space_alpha,
  opt_space_numeric,
  opt_space_others,
  spaces
}

local function pat(s: string): {string}
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
      --TODO
      print("WARNING UNHANDLED STUFFS!")
      break
    end
  end

  return r
end

local function is_valid_bpe_char(c: integer): boolean
  local valid_ranges = {
    {'!', '~'},
    {'¡', '¬'},
    {'®', 'ÿ'},
  }

  for _, range in ipairs(valid_ranges) do
    local _range_min, _range_max = unpack(range)
    local range_min = utf8_.codepoint(_range_min)
    local range_max = utf8_.codepoint(_range_max)
    if c >= range_min and c <= range_max then
      return true
    end
  end

  return false
end

local function bpe_char_encoder(): {string: string}
  local r = {}

  local n = 0 --Current re-map offset
  for i = 0,255 do
    local i_as_char = utf8_.char(i)
    if is_valid_bpe_char(i) then
      --TODO BUG - This is incompatible with the simple decoder swap_kv method
      --r[i] = i_as_char
      r[i_as_char] = i_as_char
    else
      local mapped_char = utf8_.char(n+256)
      --TODO BUG - This is incompatible with the simple decoder swap_kv method
      --r[i] = mapped_char
      r[i_as_char] = mapped_char
      n = n + 1
    end
  end

  return r
end

local function bpe_char_decoder(): {string: string} -- TODO OPT
  return utils.swap_kv(bpe_char_encoder())
end

local function bpe_token_encoder(filename: string): {string: integer}
  local file = vim.fn.join(vim.fn.readfile(filename)) as string --TODO vim.fn.join declaration correct?
  return vim.json.decode(file)
end

local function bpe_token_decoder(filename: string): {integer: string} --TODO OPT
  return utils.swap_kv(bpe_token_encoder(filename))
end

local function bpe_ranks(filename: string): {string: integer}
  local file_lines = vim.fn.readfile(filename) as {string} --TODO Correct/PR vim.fn.readfile declaration in teal-types?
  --First line is a comment
  table.remove(file_lines, 1) --OPT? Expensive

  local r = {}
  for rank, bpe_pair in ipairs(file_lines) do
    r[bpe_pair] = rank
  end

  return r
end

local type Tokens = {integer}

local record TokenListItem
  symbol: string
  token: integer
end

local type TokenList = {TokenListItem}

local record Tokenizer
  Tokens: Tokens
  TokenListItem: TokenListItem
  TokenList: TokenList

  byte_encoder: {string: string}
  byte_decoder: {string: string}
  token_encoder: {string: integer}
  token_decoder: {integer: string}
  bpe_ranks: {string: integer}

  new: function(string): Tokenizer
  --TODO methods
  bpe: function(Tokenizer, string): {string}
  tokenize: function(Tokenizer, string): Tokens
  detokenize: function(Tokenizer, Tokens): string
  token_list: function(Tokenizer, string): TokenList
end

function Tokenizer.new(model_dir: string): Tokenizer
  local r:Tokenizer = {}

  r.byte_encoder = bpe_char_encoder()
  r.byte_decoder = bpe_char_decoder()
  r.token_encoder = bpe_token_encoder(model_dir.."/encoder.json")
  r.token_decoder = bpe_token_decoder(model_dir.."/encoder.json")
  r.bpe_ranks = bpe_ranks(model_dir.."/vocab.bpe")

  return r
end

local function consecutive_pairs(word: {string}): {{string}}
  local word_length = #word
  if word_length <= 1 then
    return {word}
  end

  local r = {}
  for i = 1,#word-1 do
    table.insert(r, {word[i], word[i+1]})
  end
  return r
end

local function bpe_word_from_string(text: string): {string}
  local r = {}
  for _, c in utf8_.codes(text) do
    table.insert(r, c)
  end
  return r
end

function Tokenizer.bpe(tokenizer: Tokenizer, text: string): {string} --TODO OOP
  local word = bpe_word_from_string(text)

  while true do
    local symbol_pairs = consecutive_pairs(word)
    local min_bigram: {string}
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

function Tokenizer.tokenize(tokenizer: Tokenizer, text: string): Tokens
  local tokens = {}

  --text -> pat tokens
  local pat_tokens = pat(text)
  --pat tokens -> char encoded pat tokens
  for _, pat_token in ipairs(pat_tokens) do
    local be_chars = {}
    for _, c in utf8_.codes(pat_token) do
      local be_char = tokenizer.byte_encoder[c]
      if not be_char then
        error("Unhandled byte_endcoder index: '"..c.."'")
      end
      table.insert(be_chars, be_char)
    end
    local be_pat_token = table.concat(be_chars)

    --char encoded pat tokens -> byte pair encoded tokens
    local bpe_tokens = Tokenizer.bpe(tokenizer, be_pat_token)
    --byte pair encoded tokens -> fully encoded tokens
    for _, bpe_token in ipairs(bpe_tokens) do
      local token = tokenizer.token_encoder[bpe_token]
      if not token then
        error("Unhandled token_endcoder index: '"..token.."'")
      end
      table.insert(tokens, token)
    end
  end

  return tokens
end

function Tokenizer.detokenize(tokenizer: Tokenizer, tokens: Tokens): string
  local text_chars = {}
  for _, token in ipairs(tokens) do
    local char_encoded_token = tokenizer.token_decoder[token]
    for _, c in utf8_.codes(char_encoded_token) do
      table.insert(text_chars, tokenizer.byte_decoder[c])
    end
  end
  return table.concat(text_chars)
end

--TODO REM or replace
function Tokenizer.token_list(tokenizer: Tokenizer, text: string): TokenList
  local tokens = Tokenizer.tokenize(tokenizer, text)
  local token_list = {}
  for _, token in ipairs(tokens) do
    local symbol = Tokenizer.detokenize(tokenizer, {token})
    local item: TokenListItem = {
      symbol = symbol,
      token = token,
    }
    table.insert(token_list, item)
  end
  return token_list
end

return Tokenizer
