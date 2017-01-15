" Colored text
syntax enable

" VIM Plugins
call plug#begin('~/.vim/plugged')

Plug 'dag/vim-fish' " Fish language support
"Plug 'klen/python-mode' " Python language support
Plug 'scrooloose/nerdtree' " Directory Tree
Plug 'tpope/vim-fugitive' " Git Wrapper
Plug 'ashfinal/vim-colors-paper' " Color Palette
Plug 'bling/vim-airline' " Bottom airline
Plug 'vim-airline/vim-airline-themes' " Bottom airline theme
Plug 'valloric/youcompleteme' " Autocomplete

call plug#end()

" NERDTree Bindings
map <C-n> :NERDTreeToggle<CR>

" Close Active tab
map <C-x> :x<CR>

" Split vertically
map <C-S-k> :split<CR>

" Split horizontally
map <C-S-l> :vsplit<CR>

"Line numbers
set number
set relativenumber

" Navigating over buffer
map <C-l> :bnext<CR>
map <C-h> :bprevious<CR>

" Disable Arrow keys in Escape mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Disable Arrow keys in Insert mode
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" 256 Colors
set t_Co=256

" Make background inherit from terminal color
colorscheme slate

" Airline configuration
let g:airline#extensions#tabline#enabled=1
set laststatus=2

"Airline
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:Powerline_symbols='unicode'
set laststatus=2
let g:airline#extensions#tabline#close_symbol=':p'
let g:airline_theme='luna'
