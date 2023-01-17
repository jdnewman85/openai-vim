local openai_models = require('openai_models')

local M = {}

--[[
local models = openai_models.get_all_models()
models = openai_models.filter_models_by_is_codex(models)
--models = openai_models.filter_models_by_is_text(models)
models = openai_models.filter_models_by_is_edit(models)
--vim.pretty_print(models)
local model = models[1]
]]--

local max_tokens = 80

function M.get_temp_model(endpoint, filter_codex)
  local models = openai_models.get_models_by_endpoint(endpoint)
  if filter_codex then
    models = openai_models.filter_models_by_is_codex(models)
  end
  return models[1]
end

--[[
function M.get_model(endpoint)
  return model[endpoint]
end

function M.set_model(endpoint, m)
  model[endpoint] = m
end
]]--

function M.get_max_tokens()
  return max_tokens
end

function M.set_max_tokens(max)
  max_tokens = max
end

return M
