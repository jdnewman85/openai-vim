local oa_models = require('openai_models')

local record Config
  default_models: {string: oa_models.Model}
  current_models: {string: oa_models.Model}
  max_tokens: number

  new: function(boolean): Config
  print_current_settings: function(Config)
  get_current_model: function(Config, string): oa_models.Model
  set_current_model: function(Config, string, oa_models.Model)
  get_max_tokens: function(Config): number
  set_max_tokens: function(Config, number)
end

function Config.new(default_codex_endpoints: boolean): Config
  local defaults = oa_models.Models.get_endpoint_defaults(default_codex_endpoints)
  return setmetatable(
    {
      default_models = defaults,
      current_models = defaults,
      max_tokens = 80,
    },
    { __index = Config }
  )
end

function Config:print_current_settings()
  print("Current models:")
  vim.pretty_print(self.current_models)

  print("Max Tokens: "..self.max_tokens)
end

function Config:get_current_model(endpoint: string): oa_models.Model
  return self.current_models[endpoint]
end

function Config:set_current_model(endpoint: string, model: oa_models.Model)
  self.current_models[endpoint] = model
end

function Config:get_max_tokens(): number
  return self.max_tokens
end

function Config:set_max_tokens(max: number)
  self.max_tokens = max
end

local default_codex_endpoints = true
return Config.new(default_codex_endpoints)
