call plug#begin('~/.vim/plugged')

Plug 'vlime/vlime', { 'rtp': 'vim/' }
Plug 'luochen1990/rainbow'

call plug#end()

autocmd BufReadPost,BufNewFile *.lisp call StartVlimeServer()

function! StartVlimeServer()
  if exists("g:vlime_server_started")
    return
  endif

  let l:cmd = 'sbcl --load ~/.vim/plugged/vlime/lisp/start-vlime.lisp'
  call system(l:cmd)

  let g:vlime_server_started = 1
endfunction

" rainbowの設定とか
let g:rainbow_active = 1

set title
set tabstop=2
set smartindent
