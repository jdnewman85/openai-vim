local models = require('openai_models')
local config = require('openai_config')

-- TODO Handle cancels gracefully
-- TODO Add setting of actual values

local M = {}

local function choose_model_menu()
  local model_names = models.get_models_by_endpoint('codex')
  vim.ui.select(
    model_names,
    {
      prompt = "Model Choice",
      telescope = require("telescope.themes").get_dropdown(),
    },
    function(selection)
      config.set_model(selection)
      print("Setting model to: "..selection)
    end
  )
end

local function set_max_tokens()
  vim.ui.input(
    {
      prompt = "Max Tokens: ",
      default = tostring(config.get_max_tokens()),
      kind = "max_tokens",
      --telescope = require("telescope.themes").get_ivy(),
    },
    function(max_tokens)
      config.set_max_tokens(tonumber(max_tokens))
      print("Setting max_tokens to: "..max_tokens)
    end
  )
end

function M.show_menu()
  local menu_funcs = {}
  menu_funcs['Choose Model'] = choose_model_menu
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
