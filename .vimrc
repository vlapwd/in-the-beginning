let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * call plug#begin(data_dir . '/plugged') | PlugInstall --sync | source $MYVIMRC | call plug#end()
endif

call plug#begin('~/.vim/plugged')

Plug 'vlime/vlime', { 'rtp': 'vim/' }
Plug 'luochen1990/rainbow'

call plug#end()


"------------
"vlime
"------------
autocmd BufReadPost,BufNewFile *.lisp call StartVlimeServer()
function! StartVlimeServer()
  if exists("g:vlime_server_started")
    return
  endif
  let l:cmd = 'sbcl --load ~/.vim/plugged/vlime/lisp/start-vlime.lisp'
  call system(l:cmd)
  let g:vlime_server_started = 1
endfunction


"------------
"rainbow
"------------
let g:rainbow_active = 1


"------------
"mdファイル
"------------
augroup mdHighlight
  autocmd!
  autocmd BufRead,BufNewFile *.md syntax match LineStartDash /^\s*-/
  " https://www.ditig.com/publications/256-colors-cheat-sheet
  autocmd BufRead,BufNewFile *.md highlight LineStartDash ctermfg=201
  autocmd BufRead,BufNewFile *.md highlight LineNr ctermfg=244
augroup END


"------------
"global
"------------
set title
set number
set relativenumber
set wrapscan
set tabstop=2
set smartindent
