local openai_models = require('openai_models')

local M = {}

local codex_endpoints = true
local default_models = openai_models.get_endpoint_defaults(codex_endpoints)
local current_models = default_models

local max_tokens = 80

function M.print_current_settings()
  print("Current models:")
  vim.pretty_print(current_models)

  print("Max Tokens: "..max_tokens)
end

function M.get_current_model(endpoint)
  return current_models[endpoint]
end

function M.set_current_model(endpoint, model)
  current_models[endpoint] = model
end

function M.get_max_tokens()
  return max_tokens
end

function M.set_max_tokens(max)
  max_tokens = max
end

return M
