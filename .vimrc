let data_dir = has('nim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * call plug#begin(data_dir . '/plugged') | PlugInstall --sync | source $MYVIMRC | call plug#end()
endif

call plug#begin('~/.vim/plugged')

Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'vlime/vlime', { 'rtp': 'vim/' }
Plug 'luochen1990/rainbow'
Plug 'vim-denops/denops.vim'
Plug 'shougo/ddu.vim'
Plug 'shougo/ddu-ui-ff'
Plug 'shougo/ddu-source-file_rec'
Plug 'shougo/ddu-filter-matcher_substring'
Plug 'shougo/ddu-kind-file'

call plug#end()


"------------
"denops
"------------
let g:denops#deno = '/opt/homebrew/bin/deno'


"------------
"ddu
"------------
call ddu#custom#patch_global(#{
    \   ui: 'ff',
    \   sources: [#{name: 'file_rec', params: {}}],
    \   sourceOptions: #{
    \     _: #{
    \       matchers: ['matcher_substring'],
    \     },
    \   },
    \   kindOptions: #{
    \     file: #{
    \       defaultAction: 'open',
    \     },
    \   }
    \ })


autocmd FileType ddu-ff call s:ddu_my_settings()
function! s:ddu_my_settings() abort
  nnoremap <buffer><silent> <CR>
        \ <Cmd>call ddu#ui#do_action('itemAction')<CR>
  nnoremap <buffer><silent> <Space>
        \ <Cmd>call ddu#ui#do_action('toggleSelectItem')<CR>
  nnoremap <buffer><silent> i
        \ <Cmd>call ddu#ui#do_action('openFilterWindow')<CR>
  nnoremap <buffer><silent> q
        \ <Cmd>call ddu#ui#do_action('quit')<CR>
endfunction

command! Tls call ddu#start({})


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


"------------
"command
"------------
function! CreateAndOpenMemo(fileName)
    let l:file = expand('./' . a:fileName . '.md')
    if !filereadable(l:file)
        call system('touch ' . shellescape(l:file))
    endif
    execute 'split ' . l:file
endfunction

command! -nargs=1 Tm call CreateAndOpenMemo(<q-args>)

function! AddTask(text)
    call system('echo ' . shellescape(a:text) . ' >> ./todo.md')
endfunction

command! -nargs=1 Tt call AddTask(<q-args>)

function! OpenFileFromList()
    let files = split(system('find . -type f'), "\n")
    if empty(files)
        echo "No files found"
        return
    endif

    let choices = map(copy(files), 'v:val . " (" . (v:key + 1) . ")"')
    let choice = inputlist(choices)

    if choice > 0 && choice <= len(files)
        execute "split " . files[choice - 1]
    endif
endfunction

command! Tls call OpenFileFromList()
