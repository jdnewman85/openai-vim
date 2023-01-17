local openai_models = require('openai_models')

local M = {}

local codex_endpoints = true
local default_models = openai_models.get_endpoint_defaults(codex_endpoints)

local max_tokens = 80

function M.get_model(endpoint)
  return default_models[endpoint]
end

function M.set_model(endpoint, model)
  default_models[endpoint] = model
end

function M.get_max_tokens()
  return max_tokens
end

function M.set_max_tokens(max)
  max_tokens = max
end

return M
