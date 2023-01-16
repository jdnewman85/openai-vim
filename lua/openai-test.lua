
--tokenizer
vim.api.nvim_set_keymap("v", "<leader>ot", "<cmd>lua require('tokenizer').tokenize_selected_text()<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>oc", "<cmd>lua require('tokenizer').clear_highlights(0)<cr>", {})
--completion
vim.api.nvim_set_keymap("v", "<leader>oo", "<cmd>lua require('openai').complete_selection()<cr>", {})
--config
vim.api.nvim_set_keymap("n", "<leader>om", "<cmd>lua require('openai_menus').show_menu()<cr>", {})

--[[
--complete later:
-- vim.api.nvim_set_keymap("v", "<leader>oo", "<cmd>lua require('openai').complete()<CR>", {noremap = true, silent = true})


--TODO Complete lua function
function isPrime(n) {

<html>
<head>

]]--
