--[[
Byte pair encoding utilities
--]]

local io = require('io')

local function bytes_to_unicode()
    --[[
    Returns list of utf-8 byte and a corresponding list of unicode strings.
    The reversible bpe codes work on unicode strings.
    This means you need a large # of unicode characters in your vocab if you want to avoid UNKs.
    When you're at something like a 10B token dataset you end up needing around 5K for decent coverage.
    This is a signficant percentage of your normal, say, 32K bpe vocab.
    To avoid that, we want lookup tables between utf-8 bytes and unicode strings.
    And avoids mapping to whitespace/control characters the bpe code barfs on.
    --]]
    local bs = {}
    for i = 33, 126 do
        table.insert(bs, i)
    end
    for i = 161, 172 do
        table.insert(bs, i)
    end
    for i = 174, 255 do
        table.insert(bs, i)
    end
    local cs = bs
    local n = 0
    for b = 0, 2^8 - 1 do
        if not table.contains(bs, b) then
            table.insert(bs, b)
            table.insert(cs, 2^8+n)
            n = n + 1
        end
    end
    local cs_chars = {}
    for i, n in ipairs(cs) do
        table.insert(cs_chars, string.char(n))
    end
    return table.zip(bs, cs_chars)
end

local function get_pairs(word)
    --[[
    Return set of symbol pairs in a word.

    Word is represented as tuple of symbols (symbols being variable-length strings).
    --]]
    local pairs = {}
    local prev_char = word[1]
    for i = 2, #word do
        local char = word[i]
        table.insert(pairs, {prev_char, char})
        prev_char = char
    end
    return pairs
end

local Encoder = {}

function Encoder:new(encoder, bpe_merges, errors)
    local self = setmetatable({}, Encoder)
    self.encoder = encoder
    self.decoder = {}
    for k, v in pairs(encoder) do
        self.decoder[v] = k
    end
    self.errors = errors or 'replace'
    self.byte_encoder = bytes_to_unicode()
    self.byte_decoder = {}
    for k, v in pairs(self.byte_encoder) do
        self.byte_decoder[v] = k
    end
    self.bpe_ranks = table.zip(bpe_merges, table.range(#bpe_merges))
    self.cache = {}
    self.pat = re.compile([['s|'t|'re|'ve|'m|'ll|'d| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+]])
    return self
end


function Encoder:bpe(token)
    if self.cache[token] then
        return self.cache[token]
    end
    local word = {}
    for i = 1, #token do
        table.insert(word, token:sub(i, i))
    end
    local pairs = get_pairs(word)
    if #pairs == 0 then
        return token
    end
    while true do
        local bigram = pairs[1]
        local min_rank = self.bpe_ranks[bigram]
        if not min_rank then
            break
        end
        for i, pair in ipairs(pairs) do
            local rank = self.bpe_ranks[pair]
            if rank and rank < min_rank then
                bigram = pair
                min_rank = rank
            end
        end
        if not self.bpe_ranks[bigram] then
            break
        end
        local first, second = unpack(bigram)
        local new_word = {}
        local i = 1
        while i <= #word do
            if word[i] == first and i < #word and word[i+1] == second then
                table.insert(new_word, first .. second)
                i = i + 2
            else
                table.insert(new_word, word[i])
                i = i + 1
            end
        end
        word = new_word
        if #word == 1 then
            break
        end
        pairs = get_pairs(word)
    end
    self.cache[token] = table.concat(word)
    return self.cache[token]
end

function Encoder:encode(text)
    text = text:gsub('%s+', ' ')
    local bpe_tokens = {}
    for token in text:gmatch(self.pat) do
        if token == ' ' then
            table.insert(bpe_tokens, token)
        else
            token = self:byte_encoder(token, self.errors)
            local bpe_token = self:bpe(token)
            table.insert(bpe_tokens, bpe_token)
        end
    end
    return table.concat(bpe_tokens)
end

function Encoder:decode(text)
    local decoded_text = ''
    local text_len = #text
    local i = 1
    while i <= text_len do
        local char = text:sub(i, i)
        if char == ' ' then
            decoded_text = decoded_text .. char
            i = i + 1
        else
            local j = i
            while j <= text_len and text:sub(j, j) ~= ' ' do
                j = j + 1
            end
            local bpe_token = text:sub(i, j-1)
            local token = self:decoder(bpe_token)
            if not token then
                token = self:bpe(bpe_token)
            end
            token = self:byte_decoder(token, self.errors)
            decoded_text = decoded_text .. token
            i = j
        end
    end
    return decoded_text
end

function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

local function path_join(...)
  local parts = {...}
  local path = parts[1]
  for i = 2, #parts do
    path = path .. '/' .. parts[i]
  end
  return path
end


local function get_encoder(model_name, models_dir)
  -- Load encoder from the saved model.
  local json_file = readAll(path_join(models_dir, model_name, 'encoder.json'))
  local encoder = vim.fn.json_decode(json_file)

  local bpe_file = readAll(path_join(models_dir, model_name, 'vocab.bpe'))
  local bpe_data = bpe_file
  local bpe_merges = {}
  for merge_str in bpe_data:gmatch('[^\n]+') do
    if merge_str ~= '' then
      table.insert(bpe_merges, {merge_str:match('^(%S+)%s+(%S+)$')})
    end
  end
  return Encoder:new(encoder, bpe_merges)
end


--return Encoder

local myEncoder = get_encoder('gpt3', './models')

vim.pretty_print(myEncoder:encode("This is a test"))
