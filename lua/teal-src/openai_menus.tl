local oa_models = require('openai_models')
local oa_config = require('openai_config')

-- TODO Handle cancels gracefully

local M = {}

local function choose_model_menu(endpoint: string)
  local default_models = oa_models.Models.defaults()
  local models = default_models:filter_by_endpoint(endpoint)
  local model_names = models.names(models)
  vim.ui.select(
    model_names,
    {
      prompt = "Model Choice",
--!      telescope = require("telescope.themes").get_dropdown(),
    },
    function(model_name: string)
      local chosen_model = default_models:find_by_name(model_name)
      oa_config:set_current_model(endpoint, chosen_model)
      print("Setting model for endpoint '"..endpoint.."' to: "..model_name)
    end
  )
end

local function choose_model_endpoint_menu()
  local default_models = oa_models.Models.defaults()
  local endpoints = default_models:endpoints()
  table.sort(endpoints)

  vim.ui.select(
    endpoints,
    {
      prompt = "Endpoint Choice",
--!      telescope = require("telescope.themes").get_dropdown(),
    },
    function(endpoint: string)
      print("Selected endpoint: "..endpoint)
      choose_model_menu(endpoint)
    end
  )
end

local function set_max_tokens()
  vim.ui.input(
    {
      prompt = "Max Tokens: ",
--!      default = tostring(oa_config:get_max_tokens()),
--!      kind = "max_tokens",
      --telescope = require("telescope.themes").get_ivy(),
    },
    function(max_tokens: string)
      oa_config:set_max_tokens(tonumber(max_tokens))
      print("Setting max_tokens to: "..max_tokens)
    end
  )
end

function M.show_menu()
  local menu_funcs: {string: function} = {}
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
--!      telescope = require("telescope.themes").get_dropdown(),
    },
    function(selection: string)
      menu_funcs[selection]()
    end
  )
end

return M
