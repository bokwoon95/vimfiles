"{{{ Plugin Manager Initialization
silent! set encoding=utf-8
silent! scriptencoding utf-8
silent! set fileencoding=utf-8
if !empty(glob('~/vimfiles/autoload/pathogen.vim')) || !empty(glob('~/.vim/autoload/pathogen.vim'))
  silent! execute pathogen#infect()
  syntax on
  filetype plugin indent on
else
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
  if has('nvim') && empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
          \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif
endif
"}}}

let mapleader = "\<Space>"
silent! set macmeta

"{{{ Meta for Terminal Vim
if !has("gui_running") && !has('nvim')
  "Bind selected meta for selected keys: dbfnp<BS> hjkl vecyq 7890 ;' st
  silent! exe "set <S-Left>=\<Esc>b"
  silent! exe "set <S-Right>=\<Esc>f"
  silent! exe "set <F31>=\<Esc>d"| "M-d
  map! <F31> <M-d>
  map <F31> <M-d>
  silent! exe "set <F32>=\<Esc>n"| "M-n
  map! <F32> <M-n>
  map <F32> <M-n>
  silent! exe "set <F33>=\<Esc>p"| "M-p
  map! <F33> <M-p>
  map <F33> <M-p>
  silent! exe "set <F34>=\<Esc>\<C-?>"| "M-BS
  map! <F34> <M-BS>
  map <F34> <M-BS>
  silent! exe "set <F35>=\<Esc>\<C-H>"| "M-BS
  map! <F35> <M-BS>
  map <F35> <M-BS>
  silent! exe "set <F13>=\<Esc>h"| "M-h
  map! <F13> <M-h>
  map <F13> <M-h>
  silent! exe "set <F14>=\<Esc>j"| "M-j
  map! <F14> <M-j>
  map <F14> <M-j>
  silent! exe "set <F15>=\<Esc>k"| "M-k
  map! <F15> <M-k>
  map <F15> <M-k>
  silent! exe "set <F16>=\<Esc>l"| "M-l
  map! <F16> <M-l>
  map <F16> <M-l>
  silent! exe "set <F17>=\<Esc>v"| "M-v
  map! <F17> <M-v>
  map <F17> <M-v>
  silent! exe "set <F18>=\<Esc>e"| "M-e
  map! <F18> <M-e>
  map <F18> <M-e>
  silent! exe "set <F19>=\<Esc>c"| "M-c
  map! <F19> <M-c>
  map <F19> <M-c>
  silent! exe "set <F20>=\<Esc>y"| "M-y
  map! <F20> <M-y>
  map <F20> <M-y>
  silent! exe "set <F21>=\<Esc>q"| "M-q
  map! <F21> <M-q>
  map <F21> <M-q>
  silent! exe "set <F22>=\<Esc>7"| "M-7
  map! <F22> <M-7>
  map <F22> <M-7>
  silent! exe "set <F23>=\<Esc>8"| "M-8
  map! <F23> <M-8>
  map <F23> <M-8>
  silent! exe "set <F24>=\<Esc>9"| "M-9
  map! <F24> <M-9>
  map <F24> <M-9>
  silent! exe "set <F25>=\<Esc>0"| "M-0
  map! <F25> <M-0>
  map <F25> <M-0>
  silent! exe "set <F26>=\<Esc>;"| "M-;
  map! <F26> <M-;>
  map <F26> <M-;>
  silent! exe "set <F27>=\<Esc>'"| "M-'
  map! <F27> <M-'>
  map <F27> <M-'>
  silent! exe "set <F28>=\<Esc>s"| "M-s
  map! <F28> <M-s>
  map <F28> <M-s>
  silent! exe "set <F29>=\<Esc>t"| "M-t
  map! <F29> <M-t>
  map <F29> <M-t>
endif
if has('macunix')
  set shell=/bin/zsh
elseif has('unix')
  if executable('zsh')
    set shell=/usr/bin/zsh
  else
    set shell=/bin/bash
  endif
endif
"}}}
"{{{ Hardcoded defaults
"{{{ moll/vim-bbye
function! s:bdelete(action, bang, buffer_name)
  let buffer = s:str2bufnr(a:buffer_name)
  let w:bbye_back = 1

  if buffer < 0
    return s:error("E516: No buffers were deleted. No match for ".a:buffer_name)
  endif

  if getbufvar(buffer, "&modified") && empty(a:bang)
    let error = "E89: No write since last change for buffer "
    return s:error(error . buffer . " (add ! to override)")
  endif

  " If the buffer is set to delete and it contains changes, we can't switch
  " away from it. Hide it before eventual deleting:
  if getbufvar(buffer, "&modified") && !empty(a:bang)
    call setbufvar(buffer, "&bufhidden", "hide")
  endif

  " For cases where adding buffers causes new windows to appear or hiding some
  " causes windows to disappear and thereby decrement, loop backwards.
  for window in reverse(range(1, winnr("$")))
    " For invalid window numbers, winbufnr returns -1.
    if winbufnr(window) != buffer | continue | endif
    execute window . "wincmd w"

    " Bprevious also wraps around the buffer list, if necessary:
    try | exe bufnr("#") > 0 && buflisted(bufnr("#")) ? "buffer #" : "bprevious"
    catch /^Vim([^)]*):E85:/ " E85: There is no listed buffer
    endtry

    " If found a new buffer for this window, mission accomplished:
    if bufnr("%") != buffer | continue | endif

    call s:new(a:bang)
  endfor

  " Because tabbars and other appearing/disappearing windows change
  " the window numbers, find where we were manually:
  let back = filter(range(1, winnr("$")), "getwinvar(v:val, 'bbye_back')")[0]
  if back | exe back . "wincmd w" | unlet w:bbye_back | endif

  " If it hasn't been already deleted by &bufhidden, end its pains now.
  " Unless it previously was an unnamed buffer and :enew returned it again.
  "
  " Using buflisted() over bufexists() because bufhidden=delete causes the
  " buffer to still _exist_ even though it won't be :bdelete-able.
  if buflisted(buffer) && buffer != bufnr("%")
    exe a:action . a:bang . " " . buffer
  endif
endfunction

function! s:str2bufnr(buffer)
  if empty(a:buffer)
    return bufnr("%")
  elseif a:buffer =~# '^\d\+$'
    return bufnr(str2nr(a:buffer))
  else
    return bufnr(a:buffer)
  endif
endfunction

function! s:new(bang)
  exe "enew" . a:bang

  setl noswapfile
  " If empty and out of sight, delete it right away:
  setl bufhidden=wipe
  " Regular buftype warns people if they have unsaved text there.  Wouldn't
  " want to lose someone's data:
  setl buftype=
  " Hide the buffer from buffer explorers and tabbars:
  setl nobuflisted
endfunction

" Using the built-in :echoerr prints a stacktrace, which isn't that nice.
function! s:error(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl NONE
  let v:errmsg = a:msg
endfunction

command! -bang -complete=buffer -nargs=? Bdelete
      \ :call s:bdelete("bdelete", <q-bang>, <q-args>)
"}}}
nnoremap <Leader>bd :Bdelete<CR>
"{{{ 907th/vim-auto-save
if exists("g:auto_save_loaded")
  finish
else
  let g:auto_save_loaded = 1
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:auto_save")
  let g:auto_save = 0
endif

if !exists("g:auto_save_silent")
  let g:auto_save_silent = 0
endif

if !exists("g:auto_save_write_all_buffers")
  let g:auto_save_write_all_buffers = 0
endif

if !exists("g:auto_save_events")
  let g:auto_save_events = ["InsertLeave", "TextChanged"]
endif

" Check all used events exist
for event in g:auto_save_events
  if !exists("##" . event)
    let eventIndex = index(g:auto_save_events, event)
    if (eventIndex >= 0)
      call remove(g:auto_save_events, eventIndex)
      echo "(AutoSave) Save on " . event . " event is not supported for your Vim version!"
      echo "(AutoSave) " . event . " was removed from g:auto_save_events variable."
      echo "(AutoSave) Please, upgrade your Vim to a newer version or use other events in g:auto_save_events!"
    endif
  endif
endfor

augroup auto_save
  autocmd!
  for event in g:auto_save_events
    execute "au " . event . " * nested call AutoSave()"
  endfor
augroup END

command AutoSaveToggle :call AutoSaveToggle()

function! AutoSave()
  if g:auto_save == 0
    return
  end

  let was_modified = s:IsModified()
  if !was_modified
    return
  end

  if exists("g:auto_save_presave_hook")
    let g:auto_save_abort = 0
    execute "" . g:auto_save_presave_hook
    if g:auto_save_abort >= 1
      return
    endif
  endif

  " Preserve marks that are used to remember start and
  " end position of the last changed or yanked text (`:h '[`).
  let first_char_pos = getpos("'[")
  let last_char_pos = getpos("']")

  call DoSave()

  call setpos("'[", first_char_pos)
  call setpos("']", last_char_pos)

  if was_modified && !&modified
    if exists("g:auto_save_postsave_hook")
      execute "" . g:auto_save_postsave_hook
    endif

    if g:auto_save_silent == 0
      echo "(AutoSave) saved at " . strftime("%H:%M:%S")
    endif
  endif
endfunction

function! s:IsModified()
  if g:auto_save_write_all_buffers >= 1
    let buffers = filter(range(1, bufnr('$')), 'bufexists(v:val)')
    call filter(buffers, 'getbufvar(v:val, "&modified")')
    return len(buffers) > 0
  else
    return &modified
  endif
endfunction

function DoSave()
  if g:auto_save_write_all_buffers >= 1
    silent! wa
  else
    silent! w
  endif
endfunction

function! AutoSaveToggle()
  if g:auto_save >= 1
    let g:auto_save = 0
    echo "(AutoSave) OFF"
  else
    let g:auto_save = 1
    echo "(AutoSave) ON"
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
"}}}
nnoremap =oa :AutoSaveToggle<CR>
let g:auto_save = 1
"{{{ tpope/vim-eunuch
if exists('g:loaded_eunuch') || &cp || v:version < 700
  finish
endif
let g:loaded_eunuch = 1

function! s:fnameescape(string) abort
  if exists('*fnameescape')
    return fnameescape(a:string)
  elseif a:string ==# '-'
    return '\-'
  else
    return substitute(escape(a:string," \t\n*?[{`$\\%#'\"|!<"),'^[+>]','\\&','')
  endif
endfunction

function! s:separator()
  return !exists('+shellslash') || &shellslash ? '/' : '\\'
endfunction

command! -bar -bang Unlink
      \ if <bang>1 && &modified |
      \   edit |
      \ elseif delete(expand('%')) |
      \   echoerr 'Failed to delete "'.expand('%').'"' |
      \ else |
      \   edit! |
      \ endif

command! -bar -bang Remove
      \ let s:file = fnamemodify(bufname(<q-args>),':p') |
      \ execute 'bdelete<bang>' |
      \ if !bufloaded(s:file) && delete(s:file) |
      \   echoerr 'Failed to delete "'.s:file.'"' |
      \ endif |
      \ unlet s:file

command! -bar -bang Delete
      \ let s:file = fnamemodify(bufname(<q-args>),':p') |
      \ execute 'bdelete<bang>' |
      \ if !bufloaded(s:file) && delete(s:file) |
      \   echoerr 'Failed to delete "'.s:file.'"' |
      \ endif |
      \ unlet s:file

command! -bar -nargs=1 -bang -complete=file Move :
      \ let s:src = expand('%:p') |
      \ let s:dst = expand(<q-args>) |
      \ if isdirectory(s:dst) || s:dst[-1:-1] =~# '[\\/]' |
      \   let s:dst .= (s:dst[-1:-1] =~# '[\\/]' ? '' : s:separator()) .
      \     fnamemodify(s:src, ':t') |
      \ endif |
      \ if !isdirectory(fnamemodify(s:dst, ':h')) |
      \   call mkdir(fnamemodify(s:dst, ':h'), 'p') |
      \ endif |
      \ let s:dst = substitute(simplify(s:dst), '^\.\'.s:separator(), '', '') |
      \ if <bang>1 && filereadable(s:dst) |
      \   exe 'keepalt saveas '.s:fnameescape(s:dst) |
      \ elseif rename(s:src, s:dst) |
      \   echoerr 'Failed to rename "'.s:src.'" to "'.s:dst.'"' |
      \ else |
      \   setlocal modified |
      \   exe 'keepalt saveas! '.s:fnameescape(s:dst) |
      \   if s:src !=# expand('%:p') |
      \     execute 'bwipe '.s:fnameescape(s:src) |
      \   endif |
      \   filetype detect |
      \ endif |
      \ unlet s:src |
      \ unlet s:dst |
      \ filetype detect

function! s:Rename_complete(A, L, P) abort
  let sep = s:separator()
  let prefix = expand('%:p:h').sep
  let files = split(glob(prefix.a:A.'*'), "\n")
  call map(files, 'v:val[strlen(prefix) : -1] . (isdirectory(v:val) ? sep : "")')
  return join(files + ['..'.s:separator()], "\n")
endfunction

command! -bar -nargs=1 -bang -complete=custom,s:Rename_complete Rename
      \ Move<bang> %:h/<args>

command! -bar -nargs=1 Chmod :
      \ echoerr get(split(system('chmod '.<q-args>.' '.shellescape(expand('%'))), "\n"), 0, '') |

command! -bar -bang -nargs=? -complete=dir Mkdir
      \ call mkdir(empty(<q-args>) ? expand('%:h') : <q-args>, <bang>0 ? 'p' : '') |
      \ if empty(<q-args>) |
      \  silent keepalt execute 'file' s:fnameescape(expand('%')) |
      \ endif

command! -bar -bang -complete=file -nargs=+ Find   exe s:Grep(<q-bang>, <q-args>, 'find')
command! -bar -bang -complete=file -nargs=+ Locate exe s:Grep(<q-bang>, <q-args>, 'locate')
function! s:Grep(bang,args,prg) abort
  let grepprg = &l:grepprg
  let grepformat = &l:grepformat
  let shellpipe = &shellpipe
  try
    let &l:grepprg = a:prg
    setlocal grepformat=%f
    if &shellpipe ==# '2>&1| tee' || &shellpipe ==# '|& tee'
      let &shellpipe = "| tee"
    endif
    execute 'grep! '.a:args
    if empty(a:bang) && !empty(getqflist())
      return 'cfirst'
    else
      return ''
    endif
  finally
    let &l:grepprg = grepprg
    let &l:grepformat = grepformat
    let &shellpipe = shellpipe
  endtry
endfunction

function! s:SilentSudoCmd(editor) abort
  let cmd = 'env SUDO_EDITOR=' . a:editor . ' VISUAL=' . a:editor . ' sudo -e'
  let local_nvim = has('nvim') && len($DISPLAY . $SECURITYSESSIONID)
  if !has('gui_running') && !local_nvim
    return ['silent', cmd]
  elseif !empty($SUDO_ASKPASS) ||
        \ filereadable('/etc/sudo.conf') &&
        \ len(filter(readfile('/etc/sudo.conf', 50), 'v:val =~# "^Path askpass "'))
    return ['silent', cmd . ' -A']
  else
    return [local_nvim ? 'silent' : '', cmd]
  endif
endfunction

function! s:SudoSetup(file) abort
  if !filereadable(a:file) && !exists('#BufReadCmd#'.s:fnameescape(a:file))
    execute 'autocmd BufReadCmd ' s:fnameescape(a:file) 'exe s:SudoReadCmd()'
  endif
  if !filewritable(a:file) && !exists('#BufWriteCmd#'.s:fnameescape(a:file))
    execute 'autocmd BufReadPost ' s:fnameescape(a:file) 'set noreadonly'
    execute 'autocmd BufWriteCmd ' s:fnameescape(a:file) 'exe s:SudoWriteCmd()'
  endif
endfunction

let s:error_file = tempname()

function! s:SudoError() abort
  let error = join(readfile(s:error_file), " | ")
  if error =~# '^sudo' || v:shell_error
    return len(error) ? error : 'Error invoking sudo'
  else
    return error
  endif
endfunction

function! s:SudoReadCmd() abort
  if &shellpipe =~ '|&'
    return 'echoerr ' . string('eunuch.vim: no sudo read support for csh')
  endif
  silent %delete_
  let [silent, cmd] = s:SilentSudoCmd('cat')
  execute silent 'read !' . cmd . ' "%" 2> ' . s:error_file
  let exit_status = v:shell_error
  silent 1delete_
  setlocal nomodified
  if exit_status
    return 'echoerr ' . string(s:SudoError())
  endif
endfunction

function! s:SudoWriteCmd() abort
  let [silent, cmd] = s:SilentSudoCmd('tee')
  let cmd .= ' "%" >/dev/null'
  if &shellpipe =~ '|&'
    let cmd = '(' . cmd . ')>& ' . s:error_file
  else
    let cmd .= ' 2> ' . s:error_file
  endif
  execute silent 'write !'.cmd
  let error = s:SudoError()
  if !empty(error)
    return 'echoerr ' . string(error)
  else
    setlocal nomodified
    return ''
  endif
endfunction

command! -bar -bang -complete=file -nargs=? SudoEdit
      \ call s:SudoSetup(fnamemodify(empty(<q-args>) ? expand('%') : <q-args>, ':p')) |
      \ if !&modified || !empty(<q-args>) |
      \   edit<bang> <args> |
      \ endif |
      \ if empty(<q-args>) || expand('%:p') ==# fnamemodify(<q-args>, ':p') |
      \   set noreadonly |
      \ endif

if exists(':SudoWrite') != 2
  command! -bar SudoWrite
        \ call s:SudoSetup(expand('%:p')) |
        \ write!
endif

function! s:SudoEditInit() abort
  let files = split($SUDO_COMMAND, ' ')[1:-1]
  if len(files) ==# argc()
    for i in range(argc())
      execute 'autocmd BufEnter' s:fnameescape(argv(i))
            \ 'if empty(&filetype) || &filetype ==# "conf"'
            \ '|doautocmd filetypedetect BufReadPost' s:fnameescape(files[i])
            \ '|endif'
    endfor
  endif
endfunction
if $SUDO_COMMAND =~# '^sudoedit '
  call s:SudoEditInit()
endif

command! -bar -nargs=? Wall
      \ if empty(<q-args>) |
      \   call s:Wall() |
      \ else |
      \   call system('wall', <q-args>) |
      \ endif
if exists(':W') !=# 2
  command! -bar W Wall
endif
function! s:Wall() abort
  let tab = tabpagenr()
  let win = winnr()
  let seen = {}
  if !&readonly && expand('%') !=# ''
    let seen[bufnr('')] = 1
    write
  endif
  tabdo windo if !&readonly && &buftype =~# '^\%(acwrite\)\=$' && expand('%') !=# '' && !has_key(seen, bufnr('')) | silent write | let seen[bufnr('')] = 1 | endif
execute 'tabnext '.tab
execute win.'wincmd w'
endfunction

augroup eunuch
  autocmd!
  autocmd BufNewFile  * let b:brand_new_file = 1
  autocmd BufWritePost * unlet! b:brand_new_file
  autocmd BufWritePre *
        \ if exists('b:brand_new_file') |
        \   if getline(1) =~ '^#!/' |
        \     let b:chmod_post = '+x' |
        \   endif |
        \ endif
  autocmd BufWritePost,FileWritePost * nested
        \ if exists('b:chmod_post') && executable('chmod') |
        \   silent! execute '!chmod '.b:chmod_post.' "<afile>"' |
        \   edit |
        \   unlet b:chmod_post |
        \ endif

  autocmd BufNewFile /etc/init.d/*
        \ if filereadable("/etc/init.d/skeleton") |
        \   keepalt read /etc/init.d/skeleton |
        \   1delete_ |
        \ endif |
        \ set ft=sh
augroup END
"}}}
"}}}
"{{{ Plugin Settings
"{{{ NERDTree
nnoremap <F2> :NERDTreeToggle<CR>
nnoremap <C-x><C-n> :NERDTreeToggle<CR>
let NERDTreeAutoDeleteBuffer=1 "auto-delete buffers that have been renamed, moved or deleted
let NERDTreeMouseMode=2 "directories need one click to open, files need two clicks
let NERDTreeMinimalUI=1 "hide '?' and 'bookmarks' label
let NERDTreeMapJumpNextSibling='<C-n>'
let NERDTreeMapJumpPrevSibling='<C-p>'
let NERDTreeMapPreview='<M-k>'
let NERDTreeHighlightCursorline=1
let NERDTreeHijackNetrw=1
"}}}
"{{{ CtrlP
let g:ctrlp_map = ''
let g:ctrlp_working_path_mode = 'rw'
let g:ctrlp_show_hidden = 1
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40
let g:ctrlp_custom_ignore = {
      \ 'dir':  '\.git$\|\.yardoc\|public$|log\|tmp$',
      \ 'file': '\.so$\|\.dat$|\.DS_Store$'
      \ }
let g:ctrlp_prompt_mappings = {
      \ 'PrtSelectMove("j")':   ['<c-j>', '<c-n>'],
      \ 'PrtSelectMove("k")':   ['<c-k>', '<c-p>'],
      \ 'PrtHistory(-1)':       ['<down>'],
      \ 'PrtHistory(1)':        ['<up>'],
      \ }
nnoremap <C-c>f :CtrlPMRU<CR>
nnoremap <C-x><C-b> :CtrlPBuffer<CR>
"}}}
"{{{ Undotree
nnoremap <C-x><C-u> :UndotreeToggle<CR>
let g:undotree_WindowLayout=4
let g:undotree_SetFocusWhenToggle=1
let g:undotree_DiffpanelHeight=15
function! g:Undotree_CustomMap()
  nmap <buffer> <C-g> <plug>UndotreeClose
  nmap <buffer> <CR> <plug>UndotreeClose
endfunc
"}}}
"{{{ indentLine
let g:indentLine_enabled=1
let g:indentLine_char='¦'
let g:indentLine_color_term = 237
nnoremap <Leader>il :IndentLinesToggle<CR>
"}}}
"{{{ argwrap
nnoremap <silent> <leader>aw :ArgWrap<CR>
"}}}
"{{{ linediff
xnoremap <Leader>ld :Linediff<CR>
"}}}
"{{{ anzu
nmap n <Plug>(anzu-n-with-echo)
nmap N <Plug>(anzu-N-with-echo)
nmap * <Plug>(anzu-star-with-echo)
nmap # <Plug>(anzu-sharp-with-echo)
" clear status
nmap <Esc><Esc> <Plug>(anzu-clear-search-status)
"}}}
"{{{ vem-tabline
let g:vem_tabline_show=1
let g:vem_tabline_multiwindow_mode=0
"}}}
"{{{ vim-slime
if empty(glob('~/.slime_paste')) && !has('win32')
  silent! !touch ~/.slime_paste
endif
let g:slime_paste_file = '~/.slime_paste'
if !has('gui_running') && $TMUX != ""
  let g:slime_target = "tmux"
  let g:slime_default_config = {"socket_name": split($TMUX, ",")[0], "target_pane": ":.1"}
elseif has('nvim')
  let g:slime_target = "neovim"
elseif !has('nvim')
  let g:slime_target = "vimterminal"
endif
let g:slime_no_mappings=1
cabbrev slimc let @s=split($TMUX, ",")[0] \| SlimeConfig
xmap <C-c><C-e> <Plug>SlimeRegionSend
nmap <C-c><C-e> <Plug>SlimeParagraphSend
nmap <C-c><C-s> <Plug>SlimeLineSend
"}}}
"{{{ vim-matchup
let g:matchup_matchparen_status_offscreen = 0
"}}}
"{{{ CtrlSF
nnoremap <Leader>cf :CtrlSF<Space>
nmap <Leader>sf <Plug>CtrlSFCwordExec
xmap <Leader>sf <Plug>CtrlSFVwordExec
let g:ctrlsf_position = 'bottom'
let g:ctrlsf_auto_focus = {
      \ "at": "start"
      \ }
let g:ctrlsf_auto_close = {
      \ "normal" : 1,
      \ "compact": 1
      \}
let g:ctrlsf_default_view_mode = 'normal'
let g:ctrlsf_mapping = {
      \"open"    : ["<CR>", "o"],
      \"openb"   : "O",
      \"split"   : "<C-O>",
      \"vsplit"  : "",
      \"tab"     : "t",
      \"tabb"    : "T",
      \"popen"   : "p",
      \"popenf"  : "P",
      \"quit"    : "<C-g>",
      \"next"    : "<C-n>",
      \"prev"    : "<C-p>",
      \"pquit"   : "<C-g>",
      \"loclist" : "",
      \"chgmode" : "M",
      \"stop"    : "<C-C>"
      \}
"}}}
"{{{ vim-signify
let g:signify_vcs_list = ['git']
nnoremap <expr> <C-c><C-g> sy#repo#get_stats() != [-1,-1,-1] ?
            \!&diff ? "
            \:SignifyDiff<CR>
            \:let g:prevwin=win_getid()<CR>
            \:let b:wsv=winsaveview()<CR>
            \:windo diffoff<CR>:windo diffthis<CR>
            \:silent! call win_gotoid(g:prevwin)<CR>
            \:silent! call winrestview(b:wsv)<CR>zz
            \": ":silent! diffoff! \| silent! tabclose<CR>
            \": ""
"}}}
"}}}

syntax enable
set hidden                     " Hide Buffers, not Kill
set autoindent                 " Autoindentation
set wildmenu                   " Show completion options in vim command line
set wildcharm=<C-z>            " Wildmenu completion for mappings
set wildmode=list:longest,full " Bash-style completion menu
set wildignorecase             " ignore case in wildmenu
set number                     " Show line numbers
set ruler                      " Show cursor position
set laststatus=2               " Always show statusbar
set backspace=2                " Enable backspace capability
set incsearch hlsearch         " Realtime searching, and persistently highlight
set wrap linebreak             " Soft-wrap long lines without breaking words into 2
set display+=lastline          " display partial lines that have been wrapped
set showcmd                    " Show commands in minibuffer
set ignorecase smartcase       " Ignore case when searching, unless capitals are used
set ts=4 sw=4 sts=4 et         " Use soft tabs
set mouse=a                    " Enable mouse in terminal
set list                       " Show hidden characters
set listchars=tab:\|\ ,trail:· " ,eol:¬
set foldopen-=block            " Prevent { & } from opening folds
set breakindent                " wrapped lines keep same level of indent visually
silent! set inccommand=nosplit " Realtime feedback for Ex Commands (NEOVIM ONLY)
set fillchars+=vert:│          " Vertical bar separator
set matchpairs+=<:>            " % can jump between <,> pairs
set whichwrap+=[,],<,>         " <Left> & <Right> keys will wrap to prev/next line
syntax sync minlines=256       " start highlighting from 256 lines backwards
set synmaxcol=300              " do not highlight very long lines
set autoread                   " Reload files if they have been changed externally
set lazyredraw                 " Wait for changes to finish before redrawing screen
set noequalalways              " Don't resize existing windows when a window is closed
set nostartofline              " Stay in the same column when doing a gg or G jump
augroup Checkt
  autocmd!
  autocmd FocusGained,BufEnter * checktime " To trigger vim's autoread on focus gained or buffer enter
  autocmd FocusGained,BufEnter * silent! SignifyRefresh
augroup END
autocmd! Filetype vim setlocal foldmethod=marker ts=2 sts=2 sw=2 et
command! GMS /^<<<<<<< .*$\|^>>>>>>> .*$\|^=======$
set foldtext=repeat('\ ',indent(v:foldstart)).foldtext()

" Survival Pack
noremap <C-j> 5gj
noremap <C-k> 5gk
noremap <C-h> 4<C-y>
noremap <C-l> 4<C-e>
nnoremap <C-x>b :ls<CR>:b<Space>
cnoremap <silent> <expr> <CR> getcmdline() == "b " ? "\<C-c>:b#\<CR>" : "\<CR>"
nnoremap <C-x><C-h> :setlocal hlsearch!<bar>set hlsearch?<CR>
" inoremap <expr> <C-y> !pumvisible() ? "\<C-o>mm\<C-o>:set paste\<CR>\<C-r>+\<C-o>:set nopaste\<CR>\<Esc>'[=']`mi" : "\<C-y>"
inoremap <expr> <C-y> !pumvisible() ? "<C-o>:set paste<CR><C-r>+<C-o>:set nopaste<CR>" : "\<C-y>"
command! TL verbose setlocal ts? sts? sw? et?
command! T2 setlocal ts=2 sts=2 sw=2 et | echo "indentation set to 2 spaces"
command! T4 setlocal ts=4 sts=4 sw=4 et | echo "indentation set to 4 spaces"
command! Tb2 setlocal ts=2 sts=2 sw=2 noet | echo "indentation set to 2-spaced Tabs"
command! Tb4 setlocal ts=4 sts=4 sw=4 noet | echo "indentation set to 4-spaced Tabs"
command! Spa setlocal paste
command! Sna setlocal nopaste
" Custom keybindings (:h normal-index for defaults) (:map <key> to check key's current mapping)
inoremap jk <Esc>`^| "doesn't work in terminal vim (see "Terminal Vim Settings" section)
nnoremap <Leader>vv :e $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>
nnoremap <C-]> :silent! tag <C-r><C-w><CR>
command! W execute 'silent! w !sudo tee "%" > /dev/null' <bar> edit!
"{{{ Saner Defaults
"Disable uncommonly used Ex mode, bind Q to something more useful
nnoremap Q @q
"Bind <Tab> to %
map <Tab> %
noremap M %
"Bind ^ to H, $ to L
noremap H g^
nnoremap L g$
onoremap L g$
xnoremap L g$h
"Indent blocks without losing visual mode
xnoremap < <gv
xnoremap > >gv
"Better increment and decrement operators
noremap + <C-a>
noremap - <C-x>
xnoremap g+ g<C-a>
xnoremap g- g<C-x>
"Swap U & gU
nnoremap U m`gU
nnoremap gU U
"Enter and <C-j> accepts popup menu selection
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <C-j> pumvisible() ? "\<C-y>" : ""
"}}}
"{{{ hjkl & movement
nnoremap <silent> h <BS>
nnoremap <silent> l <Space>
xnoremap <silent> h <BS>
xnoremap <silent> l <Space>
nnoremap <silent> <expr> k v:count == 0 ? "gk" : "k"
nnoremap <silent> <expr> j v:count == 0 ? "gj" : "j"
onoremap <silent> <expr> k gk
onoremap <silent> <expr> j gj
noremap <expr> <CR> bufname("") == "[Command Line]" ? "<CR>"  :
      \ v:count == 0 ? "<Tab>" : "Gzz"
"}}}
"{{{ Macros
nnoremap <M-;> 5zh
nnoremap <M-'> 5zl
nnoremap <Leader>ss :%s//g<Left><Left>
xnoremap <Leader>ss :s//g<Left><Left>
xnoremap <Leader>tbts :s/	/    /g<Left><Left>| "convert tab to 4 spaces for visual selection
nnoremap <Leader>tbts :%s/	/    /g<Left><Left>| "convert tab to 4 spaces in normal mode
nnoremap <Leader>rr :let b:wsv=winsaveview()<CR>
      \gg=G
      \:silent! call winrestview(b:wsv)<CR>
      \:echo 'File reindented'<CR>| "reindent file without losing cursor position
nnoremap <M-v> ^vg_| "V but w/o newline char
nnoremap yd ^yg_"_dd| "dd but w/o newline char
noremap <M-d> "_d| "Black_hole delete without saving to register
noremap Y "+y| "Copy to system clipboard in normal/visual mode
nnoremap YY "+yy| "Copy to system clipboard in normal/visual mode
nnoremap y7 m`^yg_``| "yank current line (without newline)
nnoremap Y& m`^"+yg_``| "Copy current line (without newline) to system clipboard
nnoremap <M-p> "+p| "Paste from system clipboard
nnoremap <Leader>pc :let<Space>@+=expand('%:p:h')<CR>| "copy file's directory path to clipboard
nnoremap <Leader>fc :let<Space>@+=expand('%:p')<CR>| "copy file's full path+filename to clipboard
cnoremap <C-k> <C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>| "kill from current position to EOL
cnoremap <C-y> <C-r>+
cnoremap <M-y> <C-r>"
nnoremap <Leader>ww :let b:wsv=winsaveview()<CR>
      \:let b:old_search=@/<CR>
      \:%s/\s\+$//e<CR>
      \:let @/=b:old_search<CR>
      \:silent! call winrestview(b:wsv)<CR>
      \:echo '+++ Trailing whitespaces purged +++'<CR>| "Kill all orphan whitespaces
xnoremap <silent> * :<C-u>
      \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
      \gvy/<C-R><C-R>=substitute(
      \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
      \gV:call setreg('"', old_reg, old_regtype)<CR>| "forward search for visual selection literally (ignore regex)
nnoremap <C-M-h> <C-w>p5<C-y><C-w>p| "Scroll other window upwards (normal mode)
inoremap <C-M-h> <Esc><C-w>w5<C-y><C-w>pa| "Scroll other window upwards (insert mode)
nnoremap <C-M-l> <C-w>p5<C-e><C-w>p| "Scroll other window downwards (normal mode)
inoremap <C-M-l> <Esc><C-w>w5<C-e><C-w>pa| "Scroll other window downwards (insert mode)
"tip from https://www.reddit.com/r/vim/comments/7yn0xa/editing_macros_easily_in_vim/
fun! ChangeReg() abort
  let x = nr2char(getchar())
  call feedkeys("q:ilet @" . x . " = \<c-r>\<c-r>=string(@" . x . ")\<cr>\<esc>0f'", 'n')
endfun
nnoremap cr :call ChangeReg()<CR>| "cr<register alphabet> to edit the register
nnoremap <expr> <BS> &diff && &readonly ? ":qa!<CR>" : "<C-^>"
nnoremap <M-q> @q
" xnoremap <Leader>ttt :s/\v<\a/\u&/g<CR>| " Fast and dirty titlecasing
"^basic titlecase (does not work on anything other than all small caps)
"https://taptoe.wordpress.com/2013/02/06/vim-capitalize-every-first-character-of-every-word-in-a-sentence/
" xnoremap <Leader>ttc gugv:s/\v^\a\|\:\s\a\|<%(in>\|the>\|at>\|with>\|a>\|and>\|for>\|of>\|on>\|from>\|by>)@!\a/\U&/g<CR>
"^titlecase that excludes words in the list (also works on all types of caps by converting eveything to small caps first)
":s/\v^\a|\:\s\a|<%(in>|the>|at>|with>|a>|and>|for>|of>|on>|from>|by>)@!\a/\U&/g
"^ the bar characters must be escaped ie '\|'
nnoremap <expr> <C-x><C-r> &diff ? "
      \:let g:prevwin=win_getid()<CR>
      \:let b:wsv=winsaveview()<CR>
      \:windo diffoff<CR>:windo diffthis<CR>
      \:silent! call win_gotoid(g:prevwin)<CR>
      \:silent! call winrestview(b:wsv)<CR>
      \": ""
nnoremap <expr> <C-x><C-d> &diff ? ":diffget<CR>" : ""
cmap <C-j> <Down>
nnoremap gh `[v`]| "Select last pasted text
nnoremap <expr> <C-c><C-c> bufname("") == "[Command Line]" ? ":close<CR>" : ""
" cnoremap sudow w !sudo tee % >/dev/null
fun! DuplicateLineSavePosition() abort
  let colnum = virtcol('.')
  execute "normal! yyp".colnum."|"
endfun
inoremap <C-l> <Esc>:call DuplicateLineSavePosition()<CR>a<C-g>u
command! Gitmergesearch let @/="^<<<<<<< .*$\\|^>>>>>>> .*$\\|^=======$"
fun! Checkt(...) abort
  let checkt_all = a:0 >= 1 ? a:1 : 0
  if checkt_all==1
    let currbufnr = bufnr("%")
    silent! bufdo checktime
    execute "buffer" . currbufnr
  else
    silent! checktime
  endif
  echo "+++ Buffer Refreshed +++"
endfun
command! EE call Checkt()
command! EA call Checkt(1)
fun! Bufdo(cmd) abort
  let currbufnr = bufnr("%")
  execute "bufdo " . a:cmd
  execute "buffer" . currbufnr
endfun
command! -nargs=1 -complete=command Bufdo silent call Bufdo(<q-args>)
xmap <S-Tab> %
inoremap <C-g><C-d> <C-d>| "C-t indents, C-g C-d de-indents in insert mode
command! Timestamps %s/^\s*\zs\(\d\{10}\)/\=strftime('%c', submatch(1))/g
xnoremap <expr> p '"_d"' . v:register . 'p'
xnoremap <expr> P '"_d"' . v:register . 'P'
nnoremap gf :set nohidden<CR>gf:set hidden<CR>
fun! Bw()
  set nohidden
  for i in range(1, bufnr('$'))
    if getbufvar(i, '&filetype') == "netrw"
      silent execute 'bwipeout! ' . i
    endif
  endfor
  set hidden
endfun
command! Bw call Bw()
noremap x "_x
nnoremap c "_c
nnoremap C "_C
nnoremap D "_D
function! AutoSaveWinView()
  if !exists("w:SavedBufView")
    let w:SavedBufView = {}
  endif
  let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction
" Restore current view settings.
function! AutoRestoreWinView()
  let buf = bufnr("%")
  if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
    let v = winsaveview()
    let atStartOfFile = v.lnum == 1 && v.col == 0
    if atStartOfFile && !&diff
      call winrestview(w:SavedBufView[buf])
    endif
    unlet w:SavedBufView[buf]
  endif
endfunction
" When switching buffers, preserve window view.
if v:version >= 700
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()
endif
"}}}
"{{{ Wildmenu Macros
nnoremap <M-e> :e<Space><C-z>
cnoremap <M-e> <Home><S-Right><C-w>e<End><C-z>
nnoremap <M-c>d :cd<Space><C-z>
cnoremap <M-c>d <Home><S-Right><C-w>cd<End><C-z>
cnoremap %% <Home><S-Right><S-Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \<C-r>=expand('%:h').'/'<CR><C-z>
cnoremap <M-h> <Home><S-Right><Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \~/<C-z>
cnoremap <M-d>k <Home><S-Right><Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \~/Desktop/<C-z>
cnoremap <M-v>im <Home><S-Right><Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \~/.vim/<C-z>
cnoremap <M-d>oc <Home><S-Right><Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \~/Documents/<C-z>
cnoremap <M-d>bo <Home><S-Right><Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \~/Dropbox/<C-z>
cnoremap <M-d>dc <Home><S-Right><Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \~/Dropbox/Documents/<C-z>
cnoremap <M-d>w <Home><S-Right><Right><C-\>estrpart(getcmdline(),0,getcmdpos()-1)<CR>
      \~/Downloads/<C-z>
nnoremap <Leader>nv :e<Space>~/.config/nvim/init.vim<CR>
nnoremap <Leader>iv :e<Space>~/.vim/vimrc<CR>
"}}}
"{{{ UTF8 Macros
inoremap <M-q><M-a> <C-v>u25c6<Space>| "◆ Db
inoremap <M-q><M-b> <C-v>u2022<Space>| "•
  inoremap <M-q>b <C-v>u2022<Space>| "•
inoremap <M-q><M-c> <C-v>u25e6<Space>| "◦
inoremap <M-q><M-d> <C-v>u25c7<Space>| "◇ Dw
inoremap <M-q><M-l> <C-v>u2502| "│ vv
inoremap <M-q><M-=> <C-v>u2713| "✓ OK
inoremap <M-q><M--> <C-v>u2717| "✗ XX
" ▸ u25b8
" ▹ u25b9
" ■ u25a0
" □ u25a1
":h digraph-table for a list of utf8 digraphs you can insert in vim
"}}}
"{{{ Buffer Management
nnoremap <C-s> :bn<CR>
nnoremap <C-q> :bp<CR>
nnoremap gb :buffers<CR>:buffer<Space>
" nnoremap <Leader>xbd :bp<bar>bd#<CR>| "bd w/o closing window
if !empty(globpath(&rtp, 'plugin/vem_tabline.vim'))
  if g:vem_tabline_show == 1
    nmap <Leader><Down> <Plug>vem_move_buffer_right-
    nmap <Leader><Up> <Plug>vem_move_buffer_left-
    nmap <Leader><Right> <Plug>vem_next_buffer-
    nmap <Leader><Left> <Plug>vem_prev_buffer-
    nmap <S-Down> <Plug>vem_move_buffer_right-
    nmap <S-Up> <Plug>vem_move_buffer_left-
    nmap <C-s> <Plug>vem_next_buffer-
    nmap <C-q> <Plug>vem_prev_buffer-
  endif
endif
"}}}
"{{{ Tab Management
nnoremap <Leader>tn :tabnew<CR>
nnoremap <Leader>tc :tabclose<CR>
nnoremap <Leader>te :tabedit<Space>%<CR><C-o>
"}}}
"{{{ Window Management
set splitright splitbelow " Prefer opening new splits to the right and below
nnoremap <expr> <C-w><C-q> &diff ? ":diffoff!<Bar>close<CR>" : "<C-w>c"
nnoremap <expr> <C-w><C-c> &diff ? ":diffoff!<Bar>close<CR>" : "<C-w>c"
nnoremap <expr> <C-w>c &diff ? ":diffoff!<Bar>close<CR>" : "<C-w>c"
nnoremap <expr> <C-w><C-o> &diff ? ":diffoff!<Bar>only<CR>" : "<C-w>o"
nnoremap <C-w><C-e> :enew<CR>
nnoremap <M-7> <C-w><
nnoremap <M-0> <C-w>>
nnoremap <M-8> <C-w>-
nnoremap <M-9> <C-w>+
nnoremap <M-(> 200<C-w>+
nnoremap <M-j> <C-w><C-j>
nnoremap <M-k> <C-w><C-k>
nnoremap <M-l> <C-w><C-l>
nnoremap <M-h> <C-w><C-h>
nnoremap <M-\> <C-w><C-p>
if !empty(globpath(&rtp, 'plugin/tmux_navigator.vim'))
  nnoremap <silent> <M-h> :TmuxNavigateLeft<CR>
  nnoremap <silent> <M-j> :TmuxNavigateDown<CR>
  nnoremap <silent> <M-k> :TmuxNavigateUp<CR>
  nnoremap <silent> <M-l> :TmuxNavigateRight<CR>
  nnoremap <silent> <M-\> :TmuxNavigatePrevious<CR>
  inoremap <silent> <M-h> <C-o>:TmuxNavigateLeft<CR>
  inoremap <silent> <M-j> <C-o>:TmuxNavigateDown<CR>
  inoremap <silent> <M-k> <C-o>:TmuxNavigateUp<CR>
  inoremap <silent> <M-l> <C-o>:TmuxNavigateRight<CR>
  inoremap <silent> <M-\> <C-o>:TmuxNavigatePrevious<CR>
endif
"}}}
"{{{ Emacs Emulation
nnoremap <C-c> <NOP>| "Disable default C-c behavior to use it for custom mappings
nnoremap <C-x> <NOP>| "Disable default C-x behavior to use it for custom mappings
cnoremap <expr> <C-g> getcmdtype() == "/" \|\| getcmdtype() == "?" ? "<C-g>" : "<C-c><Esc>"
nnoremap <expr> <C-g> bufname("") =~ "NERD_tree_\\d"  ? ":NERDTreeToggle<CR>" :
      \ bufname("") == "[Command Line]" ? ":close<CR>" :
      \ &filetype == "godoc" ? ":close<CR>" :
      \ getwininfo(win_getid())[0]['quickfix'] ? ":cclose<CR>" :
      \ getwininfo(win_getid())[0]['loclist'] ? ":lclose<CR>" : "<C-g>"
" see :h expression-syntax for why =~ over ==
"undo
inoremap <C-_> <C-c>u
inoremap <CR> <C-g>u<CR>
"movement
inoremap <C-b> <Left>
inoremap <expr> <C-n> pumvisible() ? "<Down>": "<C-c>gja"
inoremap <expr> <C-p> pumvisible() ? "<Up>": "<C-c>gka"
inoremap <expr> <C-M-n> pumvisible() ? "<Down><Down><Down>": "<C-c>5gja"
inoremap <expr> <C-M-p> pumvisible() ? "<Up><Up><Up>": "<C-c>5gka"
inoremap <C-f> <Right>
inoremap <M-f> <S-Right>
inoremap <M-b> <S-Left>
inoremap <C-a> <C-c>I
inoremap <C-e> <End>
"forward delete, backward delete & character delete
inoremap <M-d> <C-g>u<C-c>`^vec<C-g>u
inoremap <M-BS> <C-g>u<C-w><C-g>u
inoremap <C-BS> <C-g>u<C-w><C-g>u
inoremap <C-w> <C-g>u<C-w><C-g>u
inoremap <C-d> <Del>
"kill to EOL, kill to SOL, and kill entire line
inoremap <C-k> <C-c>`^Da
inoremap <C-M-k> <C-k>| "C-M-k replaces C-k for entering digraphs
"save
inoremap <C-x><C-s> <C-o>:w<CR>
nnoremap <C-x><C-s> :w<CR>
"paste from vim register
" inoremap <M-y> \<C-c>:set paste\<CR>a\<C-r>"\<C-c>:set nopaste\<CR>a
" inoremap <M-y> <C-r>"
inoremap <M-y> <C-o>mm<C-o>:set paste<CR><C-r>+<C-o>:set nopaste<CR><C-o>`]
"emacs misc
nnoremap <C-x><C-c> :wqa<CR>
nnoremap <C-x><C-x><C-c> :qa!<CR>
nnoremap <C-x>f :e<Space><C-r>=expand('%:h').'/'<CR><C-z>
nnoremap <C-c>l :e $MYVIMRC<CR>
nnoremap <C-x><C-k> :ls<CR>:bd<Space>
nnoremap <C-x>k :ls<CR>:bd!<Space>
"commandline bindings
cnoremap <C-a> <Home>
cnoremap <C-b> <End>
cnoremap <C-M-f> <S-Right>
cnoremap <C-M-b> <S-Left>
"vim-rsi
cnoremap <C-x><C-a> <C-a>
cnoremap <C-b> <Left>
cnoremap <expr> <C-f> getcmdpos()>strlen(getcmdline())?&cedit:"\<lt>Right>"
cnoremap <expr> <C-d> getcmdpos()>strlen(getcmdline())?"\<lt>C-d>":"\<lt>Del>"
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
"}}}
"{{{ Vim Unimpaired
"Insert space above and below
" function! s:BlankUp(count) abort
"   put!=repeat(nr2char(10), a:count)
"   ']+1
"   silent! call repeat#set("\<Plug>unimpairedBlankUp", a:count)
" endfunction
" function! s:BlankDown(count) abort
"   put =repeat(nr2char(10), a:count)
"   '[-1
"   silent! call repeat#set("\<Plug>unimpairedBlankDown", a:count)
" endfunction
" nnoremap <silent> [<Space> :<C-U>call <SID>BlankUp(v:count1)<CR>
" nnoremap <silent> ]<Space> :<C-U>call <SID>BlankDown(v:count1)<CR>
"
" "Settings
" nnoremap [ol :setlocal list<CR>
" nnoremap ]ol :setlocal nolist<CR>
" nnoremap [oh :setlocal hlsearch<CR>
" nnoremap ]oh :setlocal nohlsearch<CR>
" inoremap <C-x><C-h> <C-o>:setlocal hlsearch!<bar>set hlsearch?<CR>
" nnoremap [os :setlocal spell<CR>
" nnoremap ]os :setlocal nospell<CR>
" nnoremap [od :diffthis<CR>
" nnoremap ]od :diffoff<CR>
nnoremap [wd :let g:prevwin=win_getid()<CR>
      \:let b:wsv=winsaveview()<CR>
      \:windo diffthis<CR>
      \:silent! call win_gotoid(g:prevwin)<CR>
      \:silent! call winrestview(b:wsv)<CR>
nnoremap ]wd :let b:wsv=winsaveview()<CR>
      \:diffoff!<CR>
      \:silent! call winrestview(b:wsv)<CR>
" nnoremap [on :setlocal number<CR>
" nnoremap ]on :setlocal nonumber<CR>
" nnoremap [oc :setlocal cursorline<CR>
" nnoremap ]oc :setlocal nocursorline<CR>
" nnoremap [ov :setlocal virtualedit=all<CR>
" nnoremap ]ov :setlocal virtualedit=<CR>
" nnoremap [b :bprev<CR>
" nnoremap ]b :bnext<CR>
" nnoremap [l :lprevious<CR>
" nnoremap ]l :lnext<CR>
" nnoremap [q :cprevious<CR>
" nnoremap ]q :cnext<CR>
"}}}
"{{{ Vim Tips
" To apply macros to multiple lines, highlight the lines and :norm!@@
" v/foo/e will jump the visual selection to the next instance of foo (without incsearch)
"   v/foo if you have incsearch. You can <C-g> & <C-t> to jump to the next/previous instance of foo
" <C-g> in normal mode will show the full path for the current file
" g<C-g> in a visual selection will print line/char/byte count of selection
" ga or g8 will show ascii/utf8 code of current character
" <C-f> in commandline mode will open a new editable window in normal mode
"   this also allows you to view your past search/command history
" Yank to a Capital letter register (eg A instead of a) to append to it, rather than overwriting it
" <C-w>[number]| resizes a window's columns to that number, use '-' for height
" <C-w><C-x> swaps the position of the current and alternate window
" <C-o>[number]i[character] will insert [character] [number] amount of times in the same line while in insert mode. Skip <C-o> if you start in normal mode
" :set bl to set buflisted an unlisted buffer (such as help files)
" :scriptnames to see loaded script order
" :map to see your loaded keymappings
" :command to see loaded commands
" :registers to see your registers
" :oldfiles to see your previously opened files
" using an empty pattern with :s e.g. :s//<whatever>/g will use the last search result with / as your pattern instead
" yl to copy current character under cursor (instead of vy)
" <C-d> in commandline mode to reveal all available options (like with wildmenu)
" RSs,HML,Z<as prefix>,Q,U,+-_,<Space><BS><CR> are all (uncommonly) used keys (or keys with commonly used equivalents) safe for rebinding
" <C-g> & <C-t> will jump to next/previous term while searching without having to press Enter
" echo winwidth(0) to get the current window width (same for height)
" :cq to exit vim with abnormal exit status, useful to abort git commit messages
" <C-x><C-l> in insert mode to autocomplete entire lines present in the buffer
" :%s/^/\=printf('%03d', line('.')) create a padded column of incrementing numbers
" You can pipe the regex matches from :global into :substitute!
" vim --startuptime vim.log to profile your vim startup
" \_. is the turbo version of . which matches newline characters, allowing for regex matching over multiple lines
" :redir @<register> to start recording Ex command outputs to <register>, :redir END to stop
" To specify a case sensitive search pattern, append '\C'. (conversely, '\c' for a case insensitivite pattern)
"}}}
"{{{ iabbreviations nonrecursive
"The double backslash is needed so vim doesn't complain
inoreabbr \lambda\ λ<C-r>=Eatchar('\m\s\<Bar>/')<CR>
inoreabbr \time\ <C-r>=strftime("%d-%b-%Y @ %H:%M")<CR><C-r>=Eatchar('\m\s\<Bar>/')<CR>
inoreabbr \date\ <C-r>=strftime("%d-%b-%Y")<CR><C-r>=Eatchar('\m\s\<Bar>/')<CR>
"}}}
"{{{ Views
set viewoptions=folds "let vop save only folds, and nothing else
fun! Makeview(...) abort
  let b:force_makeview = a:0 >= 1 ? a:1 : 0
  let b:viewfolder = expand('%:p:h') . "/.v__views"
  let b:viewfile = b:viewfolder . "/v__" . expand('%:t:r') . expand('%:e')
  if filereadable(b:viewfile) || b:force_makeview==1
    if b:force_makeview==1 "I suspect this is a bug that the cursor keeps gg-ing
      execute "execute mkdir('" . b:viewfolder . "', 'p')"
    endif
    let w:v = winsaveview()
    execute "mkview! ".b:viewfile
    execute "keepalt vsplit ".b:viewfile."| 3d _| w| bd"
    if b:force_makeview==1
      echo "saved view in ".b:viewfile
    endif
    call winrestview(w:v)
  endif
endfun
fun! Loadview(...) abort
  let b:force_loadview = a:0 >= 1 ? a:1 : 0
  let b:viewfolder = expand('%:p:h') . "/.v__views"
  let b:viewfile = b:viewfolder . "/v__" . expand('%:t:r') . expand('%:e')
  if filereadable(b:viewfile)
    execute "silent! source ".b:viewfile
    if b:force_loadview==1
      echo "viewfile loaded from: ".b:viewfile
    endif
  else
    " this else conditional is for debugging purposes
    echo "viewfile not found in: ".b:viewfile
  endif
endfun
command! Mkview call Makeview(1)
command! MKV call Makeview(1)
command! LDV call Loadview(1)
augroup AutosaveView
  autocmd!
  au BufWrite,VimLeave * silent! call Makeview()
  " au BufWinLeave,VimLeave * silent! call Makeview()
  "    ^^^using bufwinleave triggers some buffer deleted unexpectedly by autocmd error
  au BufRead * silent! call Loadview()
augroup END
"}}}
"{{{ Spelling
set infercase
if !empty(glob('~/.vim/words'))
  set dictionary+=~/.vim/words
  set spellfile=~/.vim/spell/en.utf-8.add
elseif !empty(glob('~/vimfiles/words'))
  set dictionary+=~/vimfiles/words
  set spellfile=~/vimfiles/spell/en.utf-8.add
endif
set spellcapcheck=
" Don't mark URL-like things as spelling errors
syn match UrlNoSpell '\w\+:\/\/[^[:space:]]\+' contains=@NoSpell
" Don't count acronyms / abbreviations as spelling errors
" (all upper-case letters, at least three characters)
" Also will not count acronym with 's' at the end a spelling error
" Also will not count numbers that are part of this
" Recognizes the following as correct:
syn match AcronymNoSpell '\<\(\u\|\d\)\{2,}s\?\>' contains=@NoSpell
"}}}

" Set swap & undo file directory
" if isdirectory(expand("~/.vim/.swp"))
"   set directory^=~/.vim/.swp//
" endif
set noswapfile
if !&swapfile && !empty(globpath(&rtp, 'plugin/AutoSave.vim'))
  set updatetime=1000
endif
" if isdirectory(expand("~/.vim/.undo"))
"   set undofile
"   set undodir^=~/.vim/.undo//
"   set undolevels=100000 " Maximum number of undos
"   set undoreload=100000 " Save complete files for undo on reload if it has fewer lines
" endif

"{{{ MyHighlights
function! MyHighlights() abort
  if has('gui_running') && g:colors_name == 'onedark'
    hi VertSplit cterm=none ctermfg=103 ctermbg=none gui=none guifg=#5C6370 guibg=bg
    hi EndOfBuffer ctermfg=16 guifg=bg
    hi StatusLine   ctermfg=233  ctermbg=103 cterm=bold gui=italic guibg=#08090b guifg=#ffeecd
    hi StatusLineNC ctermfg=103 ctermbg=none cterm=none,underline guibg=bg gui=underline
    hi SignColumn ctermbg=none
    hi TabLineSel cterm=bold,underline ctermbg=16 ctermfg=7 gui=bold,underline
  else
    hi Visual ctermbg=10 ctermfg=0
    hi DiffAdd cterm=none ctermfg=232 gui=none guifg=black
    hi DiffChange cterm=none ctermfg=232 gui=none guifg=black
    hi DiffDelete cterm=none ctermfg=232 gui=none guifg=black
    hi DiffText cterm=none ctermfg=232 gui=none guifg=black
    hi TabLineFill cterm=bold ctermbg=none gui=none guibg=bg
    hi TabLineSel cterm=bold,underline ctermbg=16 ctermfg=7 guibg=bg guifg=black gui=bold,underline
    hi TabLine cterm=none ctermbg=none ctermfg=246 guibg=bg guifg=#8787af gui=none
    hi VemTablineShown cterm=none ctermbg=16 ctermfg=7 guibg=bg guifg=black
    hi Folded cterm=none ctermbg=none gui=none guibg=bg
    hi Search ctermfg=232 ctermbg=10 guifg=black guibg=Cyan1
    hi IncSearch cterm=none ctermfg=232 ctermbg=9
    hi VertSplit cterm=none ctermfg=103 ctermbg=none gui=none guifg=#000000 guibg=#e4e4e4
    hi EndOfBuffer ctermfg=16 guifg=bg
    hi MatchParen cterm=underline ctermbg=none gui=underline guibg=bg
    hi CursorLine cterm=none ctermbg=17
    hi Cursor gui=reverse guibg=bg
    hi StatusLine   ctermfg=233  ctermbg=103 cterm=bold gui=bold guibg=#bcbcbc
    hi StatusLineNC ctermfg=103 ctermbg=none cterm=none,underline guibg=bg gui=underline
    hi SpellBad ctermbg=234 ctermfg=15 cterm=bold,underline
    hi SpellCap ctermbg=234 ctermfg=14 cterm=underline
    hi ALEErrorLine cterm=bold,underline
    hi SignColumn ctermbg=none guibg=bg
    hi ColorColumn ctermbg=234 guibg=grey85
    hi SpecialKey term=bold ctermfg=237 guifg=Grey70
    hi Whitespace term=bold ctermfg=237 guifg=Grey70
    " Plugins
    hi ALEErrorLine cterm=bold,underline
    hi SignifySignAdd    cterm=bold ctermbg=none  ctermfg=green
    hi SignifySignDelete cterm=bold ctermbg=none  ctermfg=red
    hi SignifySignChange cterm=bold ctermbg=none  ctermfg=blue
    hi CocInfoFloat ctermfg=black
  endif
  hi! link StatusLineTerm   StatusLine
  hi! link StatusLineTermNC StatusLineNC
endfunction
fun! RestoreCursorPosition() abort
  if &ft =~ 'gitcommit\|gitcommit'
    return
  endif
  call setpos(".", getpos("'\""))
endfun
augroup Autocommands
  autocmd!
  autocmd ColorScheme * call MyHighlights()
  autocmd BufReadPost * call RestoreCursorPosition()
  autocmd BufNewFile,BufRead *.fish setlocal filetype=fish
  autocmd BufNewFile,BufRead *.ejs setlocal filetype=html
  autocmd BufNewFile,BufRead *.vue setlocal filetype=html
  autocmd BufEnter,BufLeave * if &buftype ==# 'terminal' | let g:t_bufnum = expand('<abuf>') | endif
  autocmd CompleteDone * pclose
augroup END
"}}}
"{{{ GUI Vim Settings
if has('gui_running')
  if !empty(globpath(&rtp, 'colors/onedark.vim'))
    colorscheme onedark
  else
    colorscheme morning
  endif
  set foldcolumn=1
  set laststatus=1
  set guioptions=
  set belloff=all
  if has('macunix')
    set linespace=1
    " set guifont=Source\ Code\ Pro:h12
    " set guifont=Go\ Mono:h12
    set guifont=FiraMono-Regular:h12
  elseif has('unix')
    set guifont=DejaVu\ Sans\ Mono\ Book
    set lines=40 columns=150
  elseif has('win32')
    if !empty(globpath(&rtp, 'colors/onedark.vim'))
      colorscheme onedark
    endif
    set guifont=Consolas:h10
    set linespace=0
    set lines=45 columns=160
  endif
endif
"}}}
"{{{ Terminal Vim Settings
if !has("gui_running")
  colorscheme default
  set background=light
  if has('nvim')
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
          \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
          \,sm:block-blinkwait175-blinkoff150-blinkon175
    silent! lang en_US.UTF-8
  else
    set ttimeoutlen=10
  endif
endif
"}}}
"{{{ WSL Clipboard Support
func! GetSelectedText()
  normal gv"xy
  let result = getreg("x")
  return result
endfunc
if !has("gui_running") && executable("clip.exe")
  xnoremap Y :call system('clip.exe', GetSelectedText())<CR>
  nnoremap YY "xyy:call system('clip.exe', GetSelectedText())<CR>
  nnoremap Y& m`^"xyg$``:call system('clip.exe', GetSelectedText())<CR>
endif
"}}}
"{{{ Statusline Settings statsett
set statusline=
set statusline+=%{has('nvim')?'[':'('}                 " [(
set statusline+=%{strlen(&ft)?&ft:'none'},             " Filetype
set statusline+=%{strlen(&fenc)?&fenc:&enc},           " Encoding
set statusline+=%{&fileformat}                         " File format (dos, unix)
set statusline+=%{has('nvim')?']':')'}                 " ])
set statusline+=\ %f                                   " t filename, f relative filepath, F absolute filepath
set statusline+=%{&modified?'\ +':''}                  " Show '+' when file has been modified
set statusline+=%{&readonly?'\ [RO]':''}               " Show 'RO' when file is in readonly
set statusline+=%{!&modifiable?'\ [noma]':''}          " Show 'noma' when file is nonmodifiable
set statusline+=%=                                     " Right align
set statusline+=\ %{exists('g:loaded_obsession')?ObsessionStatus():''} " Obsession status
set statusline+=\ %{exists('g:loaded_fugitive')?fugitive#head(7):''}    " Git branch
set statusline+=\ %(%l,%c%V%)                          " Show line, column, virtual column (denoted with a '-' in front)
set statusline+=\ %3p%%\                               " Percentage of file shown
set statusline+=%{has('nvim')?'[':'('}                 " [(
set statusline+=%(%{'help'!=&filetype?bufnr('%'):''}%) " Buffer number
set statusline+=%{has('nvim')?']':')'}                 " ])
"}}}

"{{{ Vim Functions
"{{{ Nr2Bin
" The function Nr2Bin() returns the binary string representation of a number
func! Nr2Bin(nr)
  let n = a:nr
  let r = ""
  while n
    let r = '01'[n % 2] . r
    let n = n / 2
  endwhile
  return r
endfunc
"}}}
"{{{ ConvertBase.vim
" Convert from decimal to a named base.
function! ConvertToBase(int, base)
  if (a:base < 2 || a:base > 36)
    echohl ErrorMsg
    echo "Bad base - must be between 2 and 36."
    echohl None
    return ''
  endif
  if (a:int == 0)
    return 0
  endif
  let out=''
  let isnegative = 0
  let int=a:int
  if (int < 0)
    let isnegative = 1
    let int = - int
  endif
  while (int != 0)
    let out = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"[(int % a:base)] . out
    let int = int / a:base
  endwhile
  if isnegative
    let out = '-' . out
  endif
  return out
endfunction
" Convert from a named base to decimal.  Stop at any character that isn't a
" "base digit" (that is, an invalid character).
function! ConvertFromBase(str, base)
  let saveignorecase = &ignorecase
  let &ignorecase = 1
  if (a:base < 2 || a:base > 36)
    echohl ErrorMsg
    echo "Bad base - must be between 2 and 36."
    echohl None
    return ''
  endif
  if (a:str == '0')
    return 0
  endif
  let isnegative = 0
  let str = a:str
  if (str[0] == '-')
    let isnegative = 1
    let str = strpart(str,1,strlen(str))
  endif
  let out = 0
  let pos = 0
  let len = strlen(str)
  while (len > 0)
    let thisdigit = match("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", str[pos])
    if (thisdigit < 0 || thisdigit > a:base)
      break
    endif
    let i = 1
    let mult = 1
    while (i < len)
      let mult = a:base * mult
      let i = i + 1
    endwhile
    let len = len - 1
    let pos = pos + 1
    let thisdigit = thisdigit * mult
    let out = out + thisdigit
  endwhile
  let &ignorecase = saveignorecase
  if isnegative
    let out = '-' . out
  endif
  return out
endfunction
" Convert from a named base to a named base.
function! ConvertBases(str, base1, base2)
  let out = ConvertFromBase(a:str, a:base1)
  return ConvertToBase(out, a:base2)
endfunction
"}}}
"{{{ /search suggestions
" function! s:search_mode_start()
"     cnoremap <buffer> <Tab> <C-f>a<C-n>
"     let s:old_complete_opt = &completeopt
"     set completeopt-=noinsert
" endfunction
" function! s:search_mode_stop()
"     let &completeopt = s:old_complete_opt
" endfunction
" augroup SearchSuggestions
"   autocmd!
"   silent! cunmap <Tab>
"   autocmd CmdlineEnter /,\? call <SID>search_mode_start()
"   autocmd CmdlineLeave /,\? call <SID>search_mode_stop()
" augroup END
"}}}
"{{{ TrimEndLines
function! TrimEndLines()
  let save_cursor = getpos(".")
  :silent! %s#\($\n\s*\)\+\%$##
  call setpos('.', save_cursor)
endfunction
command! TrimEndLines call TrimEndLines()
"}}}
"{{{ Consume iabbr trailing space
"https://stackoverflow.com/questions/11858927/preventing-trailing-whitespace-when-using-vim-abbreviations
function! Eatchar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunction
"}}}
"{{{ Redir
" https://gist.github.com/romainl/eae0a260ab9c135390c30cd370c20cd7
function! Redir(cmd)
  for win in range(1, winnr('$'))
    if getwinvar(win, 'scratch')
      execute win . 'windo close'
    endif
  endfor
  if a:cmd =~ '^!'
    let output = system(matchstr(a:cmd, '^!\zs.*'))
  else
    redir => output
    execute a:cmd
    redir END
  endif
  vnew
  let w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nonumber
  call setline(1, split(output, "\n"))
endfunction
command! -nargs=1 -complete=command Redir silent call Redir(<q-args>)
" Usage:
" 	:Redir hi ............. show the full output of command ':hi' in a scratch window
" 	:Redir !ls -al ........ show the full output of command ':!ls -al' in a scratch window
"}}}
"{{{ KeepOpen
fun! KeepOpen(...)
  let l:exclude = map(copy(a:000), {i,x -> str2nr(x)})
  let l:buflist = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let g:dellist = filter(l:buflist, {i,x -> !(index(l:exclude, x) >= 0)})
  if len(g:dellist) > 1
    execute 'bd ' . join(g:dellist, ' ')
  endif
endfun
command! -nargs=+ KeepOpen call KeepOpen(<f-args>)
nnoremap <C-c><C-k> :ls<CR>:KeepOpen<Space>
"}}}
"}}}

"{{{ :terminal settings
tnoremap <C-\><C-\> <C-\><C-n>
augroup Terminal
  autocmd!
  if has('nvim')
    autocmd TermOpen * setlocal nonumber norelativenumber
    autocmd TermOpen,BufWinEnter,WinEnter * if &buftype == 'terminal' |startinsert| endif
  else
    autocmd BufWinEnter,WinEnter * if &buftype == 'terminal' |silent! normal i| endif
  endif
augroup END
nnoremap <expr> q &buftype == "terminal" ? "i" : "q"
fun! Term(...) abort
  let l:currmax=0
  let l:currbufnr=bufnr('%')
  for l:bn in range(1,bufnr('$'))
    let l:bufname = bufname(l:bn)
    let l:shellnr = str2nr(l:bufname[10:-1])
    if bufloaded(l:bn) && l:bufname =~# "term:shell.*" && l:shellnr > l:currmax
      let l:currmax = l:shellnr
    endif
  endfor
  let l:name =
        \(a:0 > 0 && a:1 != "")   ? "term:" . a:1  :
        \exists("b:lasttermname") ? b:lasttermname :
        \"term:shell".(l:currmax+1)
  if bufwinnr(l:name) > 0
    execute bufwinnr(l:name) . "wincmd c"
  elseif bufname('%') =~# "term:.*"
    execute bufwinnr(bufname('%')) . "wincmd c"
  else
    execute float2nr((winheight(0)*0.35)) . "split"
    if bufexists(l:name)
      execute "buffer " . l:name
    else
      execute has('nvim') ? "terminal" : "terminal ++curwin"
      execute "file " . l:name
      set nobuflisted
    endif
    call setbufvar(l:currbufnr, 'lasttermname', l:name)
  endif
endfun
fun! s:termnames(ArgLead, CmdLine, CursorPos) abort
  let l:termnames = []
  for l:bn in range(1,bufnr('$'))
    if bufname(l:bn) =~# "term:.*" && bufloaded(l:bn)
      call add(l:termnames, bufname(l:bn)[5:-1])
    endif
  endfor
  return filter(l:termnames, 'v:val =~ "^'. a:ArgLead .'"')
endfun
fun! s:term(...) abort
  let name = (a:0 > 0 && a:1 != "") ? a:1  : ""
  if exists("b:lasttermname") && bufwinnr(b:lasttermname) > 0
    execute bufwinnr(b:lasttermname) . "wincmd c"
  endif
  silent call Term(name)
endfun
command! -nargs=? -complete=customlist,s:termnames Term silent call Term(<f-args>) " Term will not replace any open terminals
command! -nargs=? -complete=customlist,s:termnames T silent call s:term(<f-args>) " T will replace any open terminals
command! -nargs=? -complete=customlist,s:termnames TT silent call Term(<f-args>)
nnoremap <C-w><C-t> :call Term()<CR>
tnoremap <C-w><C-t> <C-\><C-n>:call Term()<CR>
function! LsTerms()
  redir => l:ls_ex
  silent exec 'ls!'
  redir END
  echo join(filter(split(l:ls_ex, 'line \d*'), 'v:val =~# ".*term:[^/]"'), '')
endfunction
nnoremap <C-x><C-t> :call LsTerms()<CR>:b<Space>
"}}}
"{{{ Neovim :terminal Settings
if has('nvim')
  highlight TermCursor ctermfg=1 guifg=1
  "{{{Escaping, Renaming & Opening Terminal Buffers
  tnoremap <F2> <C-\><C-n>:NERDTreeToggle<CR>
  tnoremap <C-x><C-n> <C-\><C-n>:NERDTreeToggle<CR>
  "}}}
  "{{{Buffer Management in Terminal Buffers
  tnoremap <C-s> <C-\><C-n>:bn<CR>
  tnoremap <C-q> <C-\><C-n>:bp<CR>
  tnoremap <C-x><C-b> <C-\><C-n>:Buffers<CR>
  tnoremap <C-x>b <C-\><C-n>:ls<CR>:b<Space><C-z>
  tnoremap <C-x><C-f> <C-\><C-n>:Files<CR>
  tnoremap <C-x>f <C-\><C-n>:e<Space>
  tnoremap <A-p> <C-\><C-n>:Files<CR>
  "}}}
  "{{{Window Management in Terminal Buffers
  tnoremap <A-w> <C-\><C-n><C-w>
  tnoremap <C-w> <C-\><C-n><C-w>
  tnoremap <C-w><C-w> <C-w>
  tnoremap <A-h> <C-\><C-n><C-w>h
  tnoremap <A-j> <C-\><C-n><C-w>j
  tnoremap <A-k> <C-\><C-n><C-w>k
  tnoremap <A-l> <C-\><C-n><C-w>l
  if !empty(globpath(&rtp, 'plugin/tmux_navigator.vim'))
    tnoremap <silent> <A-h> <C-\><C-n>:TmuxNavigateLeft<CR>
    tnoremap <silent> <A-j> <C-\><C-n>:TmuxNavigateDown<CR>
    tnoremap <silent> <A-k> <C-\><C-n>:TmuxNavigateUp<CR>
    tnoremap <silent> <A-l> <C-\><C-n>:TmuxNavigateRight<CR>
    tnoremap <silent> <A-\> <C-\><C-n>:TmuxNavigatePrevious<CR>
  endif
  tnoremap <A-7> <C-\><C-n><C-w><
  tnoremap <A-0> <C-\><C-n><C-w>>
  tnoremap <A-8> <C-\><C-n><C-w>-
  tnoremap <A-9> <C-\><C-n><C-w>+
  "}}}
  "{{{Tab Management in Terminal Buffers
  tnoremap <A-t><A-a><A-e> <C-\><C-n>:tabe %<CR>
  tnoremap <A-t><A-a><A-c> <C-\><C-n>:tabc<CR>
  tnoremap <A-[> <C-\><C-n>gT
  tnoremap <A-]> <C-\><C-n>gt
  "}}}
  tnoremap <C-^> <C-\><C-n>:e<Space>#<CR>| "switch from terminal to prev buffer
  tnoremap <M-z> pwd\|pbcopy<CR><C-\><C-n>:cd <C-r>+<CR>i| "make vim CWD same as terminal CWD
  tnoremap <M-e> <C-\><C-n>:e<Space>
  tnoremap <M-;> <C-\><C-n>:
  let $FZF_DEFAULT_OPTS .= ' --no-height --bind=ctrl-j:preview-down,ctrl-k:preview-up'
endif
"}}}
"{{{ Vim8 :terminal Settings
if !has('nvim')
  silent! tnoremap <c-w><c-[> <c-\><c-n>
  silent! nnoremap <expr> <c-w><c-i> &buftype ==# 'terminal' ? "i" : ""
  silent! nnoremap <expr> <c-w><c-a> &buftype ==# 'terminal' ? "a" : ""
  silent! tnoremap <c-x><c-b> <c-\><c-n>:ls<cr>:b<space>
  silent! tnoremap <c-q> <c-\><c-n>:bp<cr>
  silent! tnoremap <c-s> <c-\><c-n>:bn<cr>
  silent! cnoreabbrev termm term ++curwin
endif
"}}}
