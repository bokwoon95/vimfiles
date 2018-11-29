setlocal ts=2 sw=2 sts=2 et
setlocal formatoptions-=cro

inoremap <buffer> <C-q><C-q> console.log();<Left><Left>

nnoremap <buffer> gO :silent !open <cfile><CR>
nnoremap <buffer> K :Dash<CR>
xnoremap <buffer> K "+y:Dash <C-r>+<CR>
nnoremap <buffer> gK :Dash <cWORD><CR>

inoremap <buffer> <C-M-y> ```javascript<CR><C-o>:set paste<CR><C-r>+<C-o>:set nopaste<CR><CR>```<Esc>g^k<C-v>?```<CR>jI00\|<Esc><C-v>/```<CR>klg<C-a>gvo:s/<C-v><Tab>/  /g<CR>gv<Esc>V/```<CR>
