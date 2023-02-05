local func = require('functional')
--TODO Add cost quess to model
--TODO Add complexity rating? best/simplest

local record Model
  name: string
  endpoint: string
  max_tokens: number

  is_codex: function(Model): boolean
  is_edit: function(Model): boolean
  is_text: function(Model): boolean
end

local function is_codex_model(model: Model): boolean
  return string.find(model.name, 'code') ~= nil
end

local function is_edit_model(model: Model): boolean
  return string.find(model.name, 'edit') ~= nil
end

local function is_text_model(model: Model): boolean
  return string.find(model.name, 'text') ~= nil
end

function Model.new(name: string, endpoint: string, max_tokens: number): Model
  return setmetatable({
    name = name,
    endpoint = endpoint,
    max_tokens = max_tokens,
  }, { __index = Model })
end

function Model:is_codex(): boolean
  return is_codex_model(self)
end

function Model:is_edit(): boolean
  return is_edit_model(self)
end

function Model:is_text(): boolean
  return is_text_model(self)
end

local record Models
  {Model}

  defaults: function(): Models

  get_endpoint_defaults: function(boolean): {string: Model}

  filter_is_codex: function(Models): Models
  filter_is_edit: function(Models): Models
  filter_is_text: function(Models): Models
  filter_by_endpoint: function(Models, string): Models
  find_by_name: function(Models, string): Model
  names: function(Models): {string}
  get_endpoint_model_map: function(Models): EndpointModelMap
  endpoints: function(Models): {string}

  metamethod __index: Models
end

function Models.defaults(): Models
  return setmetatable({
    Model.new('text-davinci-003',      'completions', 4000),
    Model.new('text-curie-001',        'completions', 2048),
    Model.new('text-babbage-001',      'completions', 2048),
    Model.new('text-ada-001',          'completions', 2048),
    Model.new('code-davinci-002',      'completions', 8000),
    Model.new('code-cushman-001',      'completions', 2048),
    Model.new('text-davinci-edit-001', 'edits',       nil ),
    Model.new('code-davinci-edit-001', 'edits',       nil ),
  }, { __index = Models })
end

function Models:filter_is_codex(): Models
  return setmetatable(
    func.filter_i(self, is_codex_model),
    { __index = Models }
  ) as Models
end

function Models:filter_is_edit(): Models
  return setmetatable(
    func.filter_i(self, is_edit_model),
    { __index = Models }
  ) as Models
end

function Models:filter_is_text(): Models
  return setmetatable(
    func.filter_i(self, is_text_model),
    { __index = Models }
  ) as Models
end

function Models:filter_by_endpoint(endpoint: string): Models
  return setmetatable(
    func.filter_i(self, function(model: Model): boolean
      return model.endpoint == endpoint
    end),
    { __index = Models }
  ) as Models
end

function Models.get_endpoint_defaults(codex: boolean): {string: Model}
  --TODO User defined defaults
  local models = Models.defaults()
  if codex then
    models = models:filter_is_codex()
  end
  local r: {string:Model} = {}
  r['completions'] = models:filter_by_endpoint('completions')[1]
  r['edits'] = models:filter_by_endpoint('edits')[1]

  return r
end

--TODO Replace many model functions with methods
function Models:find_by_name(name: string): Model
  return setmetatable(
    func.find_i(self, function(model: Model): boolean
      return model.name == name
    end),
    { __index = Model }
  ) as Model
end

function Models:names(): {string}
  return func.map_i(self, function(model: Model): string
    return model.name
  end) as {string}
end

local type EndpointModelMap = {string: Models}
function Models:get_endpoint_model_map(): EndpointModelMap
  return func.reduce_i(self, {}, function(acc: EndpointModelMap, model: Model): EndpointModelMap
    local endpoint = model.endpoint
    if not acc[endpoint] then
      acc[endpoint] = {}
    end
    table.insert(acc[endpoint], model)
    return acc
  end) as EndpointModelMap
end

function Models:endpoints(): {string}
  return func.keys(self:get_endpoint_model_map()) as {string}
end

return {Model = Model, Models = Models}
