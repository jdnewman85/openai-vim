
-- Treesitter test - Node under cursor


local ts_utils = require("nvim-treesitter.ts_utils")

--[[
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
]]--






-- Find all functions via query
local ts = vim.treesitter
local ts_utils = require 'nvim-treesitter.ts_utils'

local query = [[
    (function_declaration) @matchMe
]]
local parsed_query = ts.parse_query("lua", query)

function test_get_node()
    local bufnr = 0
    local start_node = ts_utils.get_node_at_cursor()
    local parser = ts.get_parser(bufnr, "lua")
    local root = parser:parse()[1]:root()
    local start_row, _, end_row, _ = root:range()

    print_node("Node at cursor", start_node)
    print("sexpr: " .. start_node:sexpr())

    for id, node in parsed_query:iter_captures(start_node, bufnr, start_row, end_row) do
        local name = parsed_query.captures[id] -- name of the capture in the query
        print("- capture name: " .. name)
        print_node(string.format("- capture node id(%s)", id), node)
    end
end

function print_node(title, node)
    print(string.format("%s: type '%s' isNamed '%s'", title, node:type(), node:named()))
end

vim.api.nvim_set_keymap('n', '<leader><Space>', ':lua test_get_node()<CR>', { noremap = true, silent = false })
