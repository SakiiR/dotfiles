" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'tmhedberg/SimpylFold'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'imsnif/kdl.vim'
Plugin 'Lokaltog/powerline', {'rtp': 'powerline/bindings/vim/'}

Bundle 'Valloric/YouCompleteMe'



" add all your plugins here (note older versions of Vundle
" used Bundle instead of Plugin)

" ...

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

set encoding=utf-8
set clipboard=unnamedplus

set splitbelow
set splitright

" Enable folding
set foldmethod=indent
set foldlevel=99

" Navigation
map <C-l> :bnext<CR>
map <C-h> :bprevious<CR>

let g:SimpylFold_docstring_preview=1

" au BufNewFile,BufRead *.py
    \ set tabstop=4
    \ set softtabstop=4
    \ set shiftwidth=4
    \ set textwidth=79
    \ set expandtab
    \ set autoindent
    \ set fileformat=unix

nnoremap <space> za

" au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

let python_highlight_all=1
syntax on

let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree

" --- Wayland clipboard ------------------------------------------------------
" vim is an XWayland client and the X11 CLIPBOARD is not bridged to niri
" unless an X window has focus, which never happens under a Wayland terminal.
if !empty($WAYLAND_DISPLAY) && executable('wl-copy')
  set clipboard=

  function! s:WlCopy() abort
    if v:event.operator !=# 'y' || v:event.regname !~# '^[+*]\=$'
      return
    endif
    let l:text = join(v:event.regcontents, "\n")
    if v:event.regtype ==# 'V'
      let l:text .= "\n"
    endif
    call system('wl-copy --type ' . shellescape('text/plain;charset=utf-8'), l:text)
  endfunction

  augroup WlClipboard
    autocmd!
    autocmd TextYankPost * call s:WlCopy()
  augroup END

  nnoremap <silent> <leader>p :call setreg('"', system('wl-paste --no-newline'), 'c')<CR>p
  nnoremap <silent> <leader>P :call setreg('"', system('wl-paste --no-newline'), 'c')<CR>P
  vnoremap <silent> <leader>p :<C-u>call setreg('"', system('wl-paste --no-newline'), 'c')<CR>gvp
endif
