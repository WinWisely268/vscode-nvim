require 'nvim_utils'
local util = require('util')
local color = require('colors')
local api = vim.api
local M = {}


local cache_dir = os.getenv('XDG_CACHE_HOME')

local function create_vimdirs()
	local vimdirs =  {
		cache_dir..'/nvim/tmp/backup',
		cache_dir..'/nvim/tmp/undo',
		cache_dir..'/nvim/tmp/sessions',
	}
	for _, d in ipairs(vimdirs) do
		util.check_create_dir(d)
	end
end

function M.setup_global_autocmd()
	local autocmds = {
		MarkdownSpell = {
			{'BufRead,BufNewFile', '*.md', 'setlocal spell' }
		},
		AutoChdir = { { 'BufEnter', '*', 'silent! lcd %:p:h' } },
		TermInsert = { { 'TermOpen', 'term://*', 'startinsert' } },
		AfterObject = {
			{ 'VimEnter', '*', "call after_object#enable('=', ':', '-', '#', ' ')" },
		},
	}
	util.create_augroups(autocmds)
end

function M.setup_options()
	create_vimdirs()
	local global_settings = {
		--- System
		clipboard     = 'unnamedplus',
		mouse         = 'a',
		autochdir     = true,
		--- Editor Behavior
		number        = true,
		relativenumber = true,
		cursorline    = true,
		expandtab     = false,
		tabstop       = 2,
		shiftwidth    = 2,
		softtabstop   = 2,
		autoindent    = true,
		list          = true,
		scrolloff     = 4,
		ttimeoutlen   = 0,
		timeout       = false,
		viewoptions   = 'cursor,folds,slash,unix',
		wrap          = true,
		tw            = 0,
		indentexpr    = '',
		foldmethod    = 'indent',
		foldlevel     = 99,
		foldenable    = true,
		splitright    = true,
		splitbelow    = true,
		showmode      = false,
		showcmd       = true,
		wildmenu      = true,
		ignorecase    = true,
		smartcase     = true,
		swapfile      = false,
		inccommand    = 'split',
		completeopt   = 'longest,noinsert,menuone,noselect,preview',
		visualbell    = true,
		backupdir     = cache_dir.."/nvim/tmp/backup,.",
		directory     = cache_dir.."/nvim/tmp/backup,.",
		undofile      = true,
		undodir       = cache_dir.."/nvim/tmp/undo,.",
		colorcolumn   = '100',
		updatetime    = 1000,
		virtualedit   = block,
		lazyredraw    = true,
		termguicolors = true,
	}

	nvim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
	nvim.command('colorscheme nord')

	for k, v in pairs(global_settings) do
		nvim.o[k] = v
	end

	local editor_setups = {
		-- These options are too pain in the butt
		-- to set from lua, hence the shortcut shit.
		"let &t_ut=''",
		"set listchars=tab:\\|\\ ,trail:▫",
		"set formatoptions-=r",
		"set shortmess+=c",
		"set number",
		"set relativenumber",
		"hi NonText ctermfg=gray guifg=grey10",
	}

	for _, v in ipairs(editor_setups) do
		vim.cmd(v)
	end

	local global_opts = {
		-- Neovim Terminal
		neoterm_autoscroll = 1,
		terminal_color_0  = color.black,
		terminal_color_1  = color.red,
		terminal_color_2  = color.green,
		terminal_color_3  = color.yellow,
		terminal_color_4  = color.blue,
		terminal_color_5  = color.magenta,
		terminal_color_6  = color.cyan,
		terminal_color_7  = color.lightgray,
		terminal_color_8  = color.darkgray,
		terminal_color_9  = color.red,
		terminal_color_10 = color.green,
		terminal_color_11 = color.yellow,
		terminal_color_12 = color.blue,
		terminal_color_13 = color.cyan,
		terminal_color_14 = color.magenta,
		terminal_color_15 = color.white,
	}
	for k, v in pairs(global_opts) do
		vim.g[k] = v
	end
end

return M
