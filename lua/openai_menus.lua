local openai_models = require('openai_models')
local openai_config = require('openai_config')

-- TODO Handle cancels gracefully
-- TODO Add setting of actual values

local M = {}

local function choose_model_menu(endpoint)
  local models = openai_models.filter_models_by_endpoint(endpoint)
  local model_names = openai_models.models_to_names(models)
  vim.ui.select(
    model_names,
    {
      prompt = "Model Choice",
      telescope = require("telescope.themes").get_dropdown(),
    },
    function(model_name)
      local chosen_model = openai_models.find_model_by_name(models, model_name)
      openai_config.set_current_model(endpoint, chosen_model)
      print("Setting model for endpoint '"..endpoint.."' to: "..model_name)
    end
  )
end

local function choose_model_endpoint_menu()
  local endpoints = openai_models.get_endpoints()

  vim.ui.select(
    endpoints,
    {
      prompt = "Endpoint Choice",
      telescope = require("telescope.themes").get_dropdown(),
    },
    function(endpoint)
      print("Selected endpoint: "..endpoint)
      choose_model_menu(endpoint)
    end
  )
end

local function set_max_tokens()
  vim.ui.input(
    {
      prompt = "Max Tokens: ",
      default = tostring(openai_config.get_max_tokens()),
      kind = "max_tokens",
      --telescope = require("telescope.themes").get_ivy(),
    },
    function(max_tokens)
      openai_config.set_max_tokens(tonumber(max_tokens))
      print("Setting max_tokens to: "..max_tokens)
    end
  )
end

function M.show_menu()
  local menu_funcs = {}
  menu_funcs['Choose Model'] = choose_model_endpoint_menu
  menu_funcs['Set Max Tokens'] = set_max_tokens

  local menu_choices = {}
  for choice in pairs(menu_funcs) do
    table.insert(menu_choices, choice)
  end
  table.sort(menu_choices)

  vim.ui.select(
    menu_choices,
    {
      prompt = "OpenAI Settings",
      telescope = require("telescope.themes").get_dropdown(),
    },
    function(selection)
      menu_funcs[selection]()
    end
  )
end

return M
