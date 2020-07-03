--- __  ____   __  _   ___     _____ __  __ ____   ____
--- |  \/  \ \ / / | \ | \ \   / /_ _|  \/  |  _ \ / ___|
--- | |\/| |\ V /  |  \| |\ \ / / | || |\/| | |_) | |
--- | |  | | | |   | |\  | \ V /  | || |  | |  _ <| |___
--- |_|  |_| |_|   |_| \_|  \_/  |___|_|  |_|_| \_\\____|
---
---  Author: @winwisely268
---  Adapted from @theniceboy, @haorenW1025, @wbthomason, @mfussenegger,
---  @theHamsta configs

-- ==
-- == Neovim init.lua
-- ==
local gmap = require('global_mappings')
local gopts = require('global_options')

-- setup global autocommands
gopts.setup_global_autocmd()

-- setup global options
gopts.setup_options()

-- setup global mappings
gmap.setup_mappings()


-- require "nvim-treesitter.configs".setup {
--	highlight = {
--		enable = true;
--	};
--	ensure_installed = {
--		"typescript",
--		"html",
--		"lua",
--		"javascript",
--		"json",
--		"java",
--		"css",
--		"c",
--		"rust",
--		"go",
--	};
-- }
