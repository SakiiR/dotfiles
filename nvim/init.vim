
"Plugins
"Managed via vim-plug
"Use :PlugInstall / :PlugClean
"Use :PlugUpdate / :PlugUpgrade
call plug#begin('~/.vim/plugged')

" Some colorscheme
Plug 'dracula/vim'

" Status bar
Plug 'vim-airline/vim-airline'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/deoplete.nvim'
Plug 'ambv/black'
Plug 'dag/vim-fish'

call plug#end()

autocmd BufWritePre *.py execute ':Black'

"Colors
set termguicolors
colorscheme dracula

set relativenumber

"Remap leader
let mapleader=";"

"Change shell (env variable)
let $SHELL = '/bin/sh'

"Splits
"Use :s and :v
cabbrev s split
cabbrev v vsplit

"Search
"Search as you type
"Highlight results
"Ignore case
set incsearch
set hlsearch
set ignorecase

"Avoid useless redraw
set lazyredraw

"Ignore some extensions in wildmenu
set wildignore+=*.so,*.o,*.swp

"Remap escape
"jj is always near
inoremap jj <Esc>

"Remap page moves
"Avoid scrolling one line by one line
noremap <C-J> }
noremap <C-K> {

"Syntax processing
syntax on

"Buffers integration
"Buffers can be hidden but still alive
"Limit buffer history for speed
"Switch buffers by using ctrl+h/l
set hidden
set history=500
nnoremap <C-H> :bprev<CR>
nnoremap <C-L> :bnext<CR>

"Identation
"2 spaces indentations
filetype plugin indent on
syntax enable
set nosmartindent
set cindent
set shiftwidth=2
set list
set expandtab
set listchars=tab:..,trail:~

"Show matching chars
"Like () or {}
set showmatch

"More than 80 chars is bad
"Show a ruller on toggle
nnoremap cc :let &cc = &cc == '' ? '119' : ''<CR>

"Signcolumns
"Avoid any unwanted background
set signcolumn=yes
hi clear SignColumn

"Status line
"Always show statusline
"Hide the mode indicator as it is built in Airline
"Hide command while typing
set laststatus=2
set noshowmode
set noshowcmd

"Airline
"Airline is the statusbar framework
"Set a matching colorscheme
"Do not use powerline
"Disable Git tracking
"Mode, Ale errors, Ale warnings, filename
"syntax, file position
let g:airline_theme='dracula'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_min_count=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#show_tab_type=0
let g:airline#extensions#default#layout=[
      \ [ 'a', 'error', 'warning', 'c' ],
      \ [ 'x', 'z' ]
      \ ]
let g:airline_section_z=airline#section#create(['%l/%L'])
let g:airline#extensions#ale#error_symbol='✗ '
let g:airline#extensions#ale#warning_symbol='✝ '
let g:airline#extensions#tagbar#enabled=0
let g:airline_symbols.readonly='O_RDONLY'
let g:airline_symbols.linenr = ''
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.branch = ''

"Enable project specific stuff
"This is provided using a local .nvimrc
"Secure avoid loading dangerous stuff
set exrc
set secure

hi Normal guibg=NONE ctermbg=NONE
set clipboard=unnamed

let g:neosnippet#snippets_directory='~/.config/nvim/snippets'
imap <C-t>     <Plug>(neosnippet_expand_or_jump)

let g:python_host_prog = $HOME.'/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = $HOME.'/.pyenv/versions/neovim3/bin/python'
