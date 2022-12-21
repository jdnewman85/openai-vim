local models = require('openai_models')

-- TODO Handle cancels gracefully
-- TODO Add setting of actual values

local M = {}

local function echo_choice(selection)
  print("Your choice: " .. selection)
end

local function choose_model_menu()
  local model_names = models.get_models_by_endpoint('codex')
  vim.ui.select(
    model_names,
    {
      prompt = "Model Choice",
      telescope = require("telescope.themes").get_dropdown(),
    },
    echo_choice
  )
end

local function set_max_tokens()
  --TODO Figure out why my input is trash? Highlight stuffs
  vim.ui.input(
    {
      prompt = "Max Tokens: ",
      default = "1000",
      telescope = require("telescope.themes").get_dropdown(),
    },
    echo_choice
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
