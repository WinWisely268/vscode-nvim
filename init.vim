" __  ____   __  _   ___     _____ __  __ ____   ____
"|  \/  \ \ / / | \ | \ \   / /_ _|  \/  |  _ \ / ___|
"| |\/| |\ V /  |  \| |\ \ / / | || |\/| | |_) | |
"| |  | | | |   | |\  | \ V /  | || |  | |  _ <| |___
"|_|  |_| |_|   |_| \_|  \_/  |___|_|  |_|_| \_\\____|

" Author: @winwisely268
" Adapted from @theniceboy, @haorenW1025, @wbthomason, @mfussenegger,
" @theHamsta configs
"
if &compatible
	set nocompatible
endif

" ==
" == Auto load for first time uses
" ==
if empty(glob('~/.config/nvim/pack/packager/opt/vim-packager'))
	silent !git clone https://github.com/kristijanhusak/vim-packager
				\ ~/.config/nvim/pack/packager/opt/vim-packager
endif


" ==
" == Create a _machine_specific.vim file to adjust machine specific stuff, like python interpreter location
" ==
let has_machine_specific_file = 1
if empty(glob('~/.config/nvim/machine_specific.vim'))
	let has_machine_specific_file = 0
	silent! exec "!cp ~/.config/nvim/default_configs/_machine_specific_default.vim ~/.config/nvim/_machine_specific.vim"
endif
source $XDG_CONFIG_HOME/nvim/machine_specific.vim

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" ===
" === Install Plugins with Vim-Packager
" ===
function! PackagerInit() abort
	packadd vim-packager
	call packager#init()
	" Async
	call packager#add('TravonteD/luajob')
	" General Utilities
	call packager#add('norcalli/nvim_utils')
	" Pretty Dress
	call packager#add('arcticicestudio/nord-vim')
endfunction

command! PackInstall call PackagerInit() | call packager#install()
command! -bang PackUpdate call PackagerInit() | call packager#update({ 'force_hooks': '<bang>' })
command! PackClean call PackagerInit() | call packager#clean()
command! PackStatus call PackagerInit() | call packager#status(

packadd! luajob
packadd! nvim_utils
packadd! vim-packager

" ==
" == Undotree
" ==
function g:Undotree_CustomMap()
	lua require('global_options').undotree_maps()
endfunc


" ==
" == Load main configs
" ==
luafile ~/.config/nvim/init.lua

" Open the _machine_specific.vim file if it has just been created
if has_machine_specific_file == 0
	exec "e ~/.config/nvim/_machine_specific.vim"
endif

