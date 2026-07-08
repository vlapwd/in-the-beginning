let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * call plug#begin(data_dir . '/plugged') | PlugInstall --sync | source $MYVIMRC | call plug#end()
endif

" Plug足したら:PlugInstall
" Install状況確認するなら:PlugStatus
" updateは:PlugUpdate
" denopsがキャッシュ持ってる可能性があるので
" ddu系を触ったらキャッシュ更新、再起動
" :call denops#cache#update(#{reload: v:true})
" :call denops#server#restart()
call plug#begin('~/.vim/plugged')

Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
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
"haskell lsp
"------------
augroup LspHaskell
    autocmd!
    autocmd FileType haskell call lsp#register_server({
        \ 'name': 'haskell-language-server',
        \ 'cmd': ['haskell-language-server-wrapper', '--lsp'],
        \ 'allowlist': ['haskell'],
        \ })
augroup END

"------------
"vim-lsp
"------------
" 自動でLSP起動
let g:lsp_auto_enable = 1
" LSPの基本設定
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes

    " 定義ジャンプ！
    nmap <buffer> gd <plug>(lsp-definition)
    " 使用箇所の検索！
    nmap <buffer> gr <plug>(lsp-references)

    " その他便利なやつ
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> K <plug>(lsp-hover)
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

"------------
"asynccomplete
"------------
" 補完を自動でトリガー
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
autocmd FileType javascript,typescript,typescriptreact,javascriptreact setlocal omnifunc=lsp#complete

let g:asyncomplete_auto_popup = 1


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
augroup END


"------------
"global
"------------
highlight LineNr ctermfg=244
set title
set number
set relativenumber
set wrapscan
set tabstop=2
set shiftwidth=2
set smartindent
set clipboard+=unnamed

let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/.vim/lsp.log')

highlight Pmenu      ctermfg=189 ctermbg=235 guifg=#cdd6f4 guibg=#1e1e2e
highlight PmenuSel   ctermfg=16 ctermbg=117 guifg=#11111b guibg=#89b4fa
highlight PmenuSbar  ctermbg=238 guibg=#45475a
highlight PmenuThumb ctermbg=117 guibg=#89b4fa

autocmd FileType qf setlocal nobuflisted

"------------
"command
"------------

" チートシート
function! OpenCheatSheet()
  split cheatsheet
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal nobuflisted
  setlocal nonumber
  setlocal norelativenumber
  setlocal noswapfile
  setlocal filetype=help
  call setline(1, [
        \ ' Vim Cheat Sheet ',
        \ '----------------',
        \ ':q      - Quit',
        \ ':w      - Save',
        \ ':wq     - Save and Quit',
        \ 'dd      - Delete line',
        \ 'yy      - Copy line',
        \ 'p       - Paste',
        \ 'u       - Undo',
        \ 'Ctrl-r  - Redo',
				\ 'Ctrl-w  - Window移動',
				\ 'n       - 次の検索結果',
				\ 'N       - 前の検索結果',
				\ '*       - 今いる単語を検索',
				\ 'gd      - 定義にジャンプ',
				\ 'gr      - 使用箇所検索',
				\ 'K       - docs表示',
				\ 'Ctrl-o  - ジャンプ先から戻る',
				\ ':LspManageServer  - Lsp一覧を開く',
        \ '',
        \ 'Press ENTER to close'
        \ ])
  nnoremap <buffer> <CR> :q<CR>
endfunction

command! Th call OpenCheatSheet()
