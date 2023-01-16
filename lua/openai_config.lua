local M = {}

--TODO Per-endpoint
local model = 'code-davinci-002'
local max_tokens = 80

function M.get_model()
  return model
end

function M.set_model(mdl)
  model = mdl
end

function M.get_max_tokens()
  return max_tokens
end

function M.set_max_tokens(max)
  max_tokens = max
end

return M
