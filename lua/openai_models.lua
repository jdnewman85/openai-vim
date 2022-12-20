local M = {}

local models = {}
models['completion'] = {
  { name = 'text-davinci-003', max_tokens = 4000, },
  { name = 'text-curie-001',   max_tokens = 2048, },
  { name = 'text-babbage-001', max_tokens = 2048, },
  { name = 'text-ada-001',     max_tokens = 2048, },
}
models['codex'] = {
  { name = 'code-davinci-002', max_tokens = 8000, },
  { name = 'code-cushman-001', max_tokens = 2048, },
}
models['edit'] = {
  { name = 'text-davinci-edit-001', max_tokens = nil, },
  { name = 'code-davinci-edit-001', max_tokens = nil, },
}

function M.get_model_map()
  return models
end

function M.get_all_models()
  local model_names = {}
  --TODO null checks for iterators
  for _, endpoint_models in pairs(models) do
    for _, model in ipairs(endpoint_models) do
      table.insert(model_names, model.name)
    end
  end
  return model_names
end

function M.get_models_by_endpoint(endpoint)
  --TODO null checks for iterators
  local model_names = {}
  local endpoint = models[endpoint]
  for _, model in ipairs(endpoint) do
    table.insert(model_names, model.name)
  end
  return model_names
end

function M.guess_price_per_1kt(model)
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
  return 9999.99
end

local function combine_tables(t1, t2)
  for _, v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end

function M.print_all_model_prices()
  print"Price guessing game!"
  local all_model_names = {}
  for _, model_group in pairs(models) do
    for _, i_model in ipairs(model_group) do
      table.insert(all_model_names, i_model.name)
    end
  end
  --vim.pretty_print(all_model_names)

  local all_model_prices = {}
  for _, model_name in ipairs(all_model_names) do
    all_model_prices[model_name] = M.guess_price_per_1kt(model_name)
  end

  vim.pretty_print(all_model_prices)
end

return M
