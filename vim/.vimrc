call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree' " Left Tree
Plug 'dag/vim-fish' " Fish language support
Plug 'airblade/vim-gitgutter' " Git Wrapper
Plug 'bling/vim-airline' " Bottom airline
Plug 'vim-airline/vim-airline-themes' " Bottom airline theme
Plug 'jiangmiao/auto-pairs' " Auto Completion for brackets
Plug 'SirVer/ultisnips' " Snippets
Plug 'honza/vim-snippets' " Snippets
Plug 'easymotion/vim-easymotion' " Better Vim Motions !!
Plug 'scrooloose/nerdcommenter' " Toggle Commenting
Plug 'ervandew/supertab' " Tab Usage
Plug 'lambdalisue/vim-gista' " Gist Handling
Plug 'python-mode/python-mode'
Plug 'chriskempson/base16-vim'
Plug 'vim-scripts/nginx.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'mhinz/vim-startify'
Plug 'mhinz/vim-janah'
Plug 'nvie/vim-flake8'
Plug 'danilo-augusto/vim-afterglow'

" Initialize plugin system
call plug#end()

filetype plugin indent on
set shiftwidth=4 tabstop=4 softtabstop=4 expandtab autoindent

"Line numbers
set number
set relativenumber
set clipboard=unnamed
"
" lateral Bindings
map <C-n> :NERDTreeToggle<CR>
map <Leader>n <plug>NERDTreeTabsToggle<CR>


" Navigating over buffer
map <C-l> :bnext<CR>
map <C-h> :bprevious<CR>
map <C-i> :vsplit<CR>
map <C-o> :split<CR>

" Save on buffer switch
set autowriteall
map <c-x> :close<CR>
map <C-k> {
map <C-j> }

" Save on buffer switch
" set autowriteall
map <c-x> :bdelete<CR>

set guifont=Monofur\ Nerd\ Font:h11

" Airline configuration
set laststatus=2
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:Powerline_symbols='unicode'
let g:airline#extensions#tabline#close_symbol=':p'
let g:airline_theme='bubblegum'

" Snippet Triggering " Trigger configuration. Do not use <tab> if you use
let g:UltiSnipsExpandTrigger="<C-t>" 
let g:UltiSnipsJumpForwardTrigger="<c-b>" 
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" Flake8
let g:flake8_cmd="/usr/local/bin/flake8"
autocmd FileType python map <buffer> <C-c> :call Flake8()<CR>
" Override go-to.definition key shortcut to Ctrl-]
let g:pymode_rope_goto_definition_bind = "gd"
let g:pymode_virtualenv = 1
let g:pymode_virtualenv_path = $VIRTUAL_ENV
let g:pymode_folding = 0

" Colors and sizing
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set t_Co=256
colorscheme afterglow
hi Normal ctermbg=none
set cc=120

" UTF-8
set encoding=utf-8

" Invisible chars etc
set list
set listchars=tab:>-,nbsp:.,trail:.,extends:>,precedes:< ",space:·

" EasyMotion
map <Leader> <Plug>(easymotion-prefix)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)
