--tokenizer
vim.api.nvim_set_keymap("v", "<leader>ot", "<cmd>lua require('tokenizer').tokenize_selected_text()<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>oc", "<cmd>lua require('tokenizer').clear_highlights(0)<cr>", {})
--completion
vim.api.nvim_set_keymap("v", "<leader>oo", "<cmd>lua require('openai').complete_selection()<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>oi", "<cmd>lua require('openai').buffer_context_insert_at_cursor()<cr>", {})
--menu
vim.api.nvim_set_keymap("n", "<leader>om", "<cmd>lua require('openai_menus').show_menu()<cr>", {})
--config
vim.api.nvim_set_keymap("n", "<leader>op", "<cmd>lua require('openai_config').print_current_settings()<cr>", {})

--[[
--TODO Complete lua function
function isPrime(n)
]]--
