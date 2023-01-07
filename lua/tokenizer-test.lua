-- TODO TEMP? Bind key
vim.api.nvim_set_keymap("v", "<leader>t", "<cmd>lua require('tokenizer').tokenize_selected_text()<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>c", "<cmd>lua require('tokenizer').clear_highlights(0)<cr>", {})

--This is a test! A Much longer test with more text. !!!!!!!! This is coolsio! y'all like's it? Hello World!
