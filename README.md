# OpenAI Vim integration plugin

Sorry, this isn't quite ready yet
Soon(TM)

Don't use it yet

# Alternatives
Here are some alternatives in the interim. I've not actually used any, and can't make any recommendations.
- [tom-doerr/vim_codex](https://github.com/tom-doerr/vim_codex)
- [aduros/ai.vim](https://github.com/aduros/ai.vim)
- [jessfraz/openai.vim](https://github.com/jessfraz/openai.vim)
- [jackMort/ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)

# WIP
Neovim only for now anyway, newish(TBD) version

Written in [Teal](https://github.com/teal-language/tl)

# TODO
- README.md
  - WIP
  - Initial release
  - Screenshots
- Example vim init
- User defined keybinds
- Example default keybinds
- Error handling

# Goals
- Integrate openai endpoints effectively
    - Operations: Complete, insert, and edit
    - Model selection and Parameter settings
- Tokenize text locally, and use treesitter to help with:
- Determining tokens to be sent to AI
    - Entire file
    - Selection
    - Up to cursor
    - Multiple marked ranges
    - Lexical scope w/ treesitter
        - Enclosing function
        - Enclosing class
        - Imported
    - Choose method based on expressions including possibly factors:
      - Operation
      - Preference/settings
      - Number of input tokens
      - Number of available tokens for output
      - Costs
      - Codex vs Text
      - Locally stored prior data, including AI prompts and responses
    - Error messages
      - All
      - W/ prompt
      - Single
      - Range
      - Selection
- Stops @ end of
  - Line
  - Function
  - Class
  - List
  - Comments
- Assist with predicting cost based on cost-per-token, selected settings, etc
  - Impossible to _guarantee_ anything here without API access to this information

## Requirements
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - curl
  - Actually requires this [forked version](https://github.com/jdnewman85/plenary.nvim) until I PR [Server Sent Events](https://en.wikipedia.org/wiki/Server-sent_events) support
- Optional
  - [utf8.nvim](https://github.com/uga-rosa/utf8.nvim) - tokenization functionality
  - [dressing.nvim](https://github.com/stevearc/dressing.nvim) - prettier menus
    - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - prettier menus
- Embeds files from
  - [Neovim types](https://github.com/teal-language/teal-types/blob/master/types/neovim/vim.d.tl) from [teal-types](https://github.com/teal-language/teal-types)

## API Key
Expects your openai api key in environment variable `OPENAI_APIKEY` - Note: *IT IS NOT A FREE SERVICE!* (though they do provide some starting credit)

## Keybinds
Terrible keybinds for the functionality so far are in [plugin/openai-test.lua](https://github.com/jdnewman85/openai-vim/blob/main/plugin/openai-test.lua)
  - They are truly terrible and temporary - I've put no thought in to them
  - They are hardcoded for development, likely end users would put everything from [plugin/openai-test.lua](https://github.com/jdnewman85/openai-vim/blob/main/plugin/openai-test.lua) in their vim init.
  - They aren't documented, wait till they are.

# May rename and generalize to other apis in the future
# MIT
