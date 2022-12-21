local ts_utils = require("nvim-treesitter.ts_utils")
local menus = require('openai_menus')


local function get_top_node_under_cursor()
  local cursor_node = ts_utils.get_node_at_cursor()
  if cursor_node == nil then
    error('No treesitter node found')
  end

  local root_node = ts_utils.get_root_for_node(cursor_node)

  return root_node
end

local node = get_top_node_under_cursor()
local bufnr = vim.api.nvim_get_current_buf()
ts_utils.update_selection(bufnr, node)
print"HI"


--menus.show_menu()
