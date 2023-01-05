
-- Treesitter test - Select function around cursor


local ts = vim.treesitter
local ts_utils = require 'nvim-treesitter.ts_utils'

local function_node_names={
  'function_declaration',
  'function_definition',
  'local_function',
  'method_definition',
  'method_declaration',
  'constructor_declaration',
}

function matchesAny(input, matches)
  for _, match in ipairs(matches) do
    if string.match(input, match) then
      return true
    end
  end
  return false
end

function select_function_at_cursor()
  local bufnr = 0
  local parser = ts.get_parser(bufnr)
  local tree = parser:parse()
  local node = ts_utils.get_node_at_cursor()
  while node and not matchesAny(node:type(), function_node_names) do
    node = node:parent()
  end
  if not node then return end
  ts_utils.update_selection(bufnr, node, 'V')
end

vim.api.nvim_set_keymap('n', '<leader><Space>', ':lua select_function_at_cursor()<CR>', { noremap = true, silent = false })
