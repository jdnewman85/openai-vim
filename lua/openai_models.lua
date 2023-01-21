local func = require('functional')

local M = {}

--TODO Add cost quess to model
--TODO Add complexity rating? best/simplest
local all_models = {
  { name = 'text-davinci-003',      endpoint = 'completions', max_tokens = 4000, },
  { name = 'text-curie-001',        endpoint = 'completions', max_tokens = 2048, },
  { name = 'text-babbage-001',      endpoint = 'completions', max_tokens = 2048, },
  { name = 'text-ada-001',          endpoint = 'completions', max_tokens = 2048, },
  { name = 'code-davinci-002',      endpoint = 'completions', max_tokens = 8000, },
  { name = 'code-cushman-001',      endpoint = 'completions', max_tokens = 2048, },
  { name = 'text-davinci-edit-001', endpoint = 'edits',       max_tokens = nil,  },
  { name = 'code-davinci-edit-001', endpoint = 'edits',       max_tokens = nil,  },
}
function M.get_endpoint_defaults(codex)
  --TODO User defined defaults
  local models = M.get_all_models()
  if codex then
    models = M.filter_models_by_is_codex(models)
  end
  local r = {}
  r['completions'] = M.filter_models_by_endpoint(models, 'completions')[1]
  r['edits'] = M.filter_models_by_endpoint(models, 'edits')[1]

  return r
end

--TODO Replace many model functions with methods
function M.filter_models_by_endpoint(models, endpoint)
  return func.filter(models, function(model)
    return model.endpoint == endpoint
  end)
end

function M.find_model_by_name(models, name)
  return func.find(models, function(model)
    return model.name == name
  end)
end

function M.filter_models_by_is_edit(models)
  return func.filter(models, function(model)
    return M.is_edit_model(model)
  end)
end

function M.filter_models_by_is_edit(models)
  return func.filter(models, M.is_edit_model(model))
end

function M.filter_models_by_is_text(models)
  return func.filter(models, M.is_text_model(model))
end

function M.filter_models_by_is_codex(models)
  return func.filter(models, M.is_codex_model(model))
end

local function add_model_prices()
  for i in ipairs(all_models) do
    local model = all_models[i]
    model['guess_price_per_1kt'] = M.guess_price_per_1kt(model.name)
  end
end

function M.is_edit_model(model)
  return string.find(model.name, 'edit')
end

function M.is_codex_model(model)
  return string.find(model.name, 'code')
end

function M.is_text_model(model)
  return string.find(model.name, 'text')
end

function M.get_all_models()
  return all_models
end

function M.get_endpoints()
  local r = {}

  --TODO Sort?
  local endpoint_model_map = M.get_endpoint_model_map()
  for endpoint in pairs(endpoint_model_map) do
    table.insert(r, endpoint)
  end

  return r
end

function M.models_to_names(models)
  return func.map(models, function(model)
    return model.name
  end)
end

function M.get_endpoint_model_map()
  local endpoint_map = {}

  for _, model in ipairs(all_models) do
    local endpoint = model.endpoint
    if not endpoint_map[endpoint] then
      endpoint_map[endpoint] = {}
    end
    table.insert(endpoint_map[endpoint], model)
  end

  return endpoint_map
end

function M.guess_price_per_1kt(model)
  --Takes model or model name
  local model_name = model
  if type(model_name) == 'table' then
    model_name = model_name.name
  end
  --TODO Replace with api if they ever provide one >.<#
  local is_edit_model = string.find(model_name, 'edit')
  local is_codex_model = string.find(model_name, 'code')

  local is_temp_free = is_edit_model or is_codex_model
  if is_temp_free then
    return 0
  end

  local model_prices = {
    ada     = 0.0004,
    babbage = 0.0005,
    curie   = 0.0020,
    davinci = 0.0200,
  }
  for m_name, m_price in pairs(model_prices) do
    local is_model = string.find(model_name, m_name)
    if is_model then
      return m_price
    end
  end

  --Not recognized
  return 9999.99 --TODO Replace magic
end

add_model_prices()

return M
