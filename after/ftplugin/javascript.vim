setlocal ts=2 sw=2 sts=2 et
set formatoptions-=cro

inoremap <C-q><C-q> console.log();<Left><Left>

nnoremap gO :silent !open <cfile><CR>
nnoremap K :Dash<CR>
xnoremap K "+y:Dash <C-r>+<CR>
nnoremap gK "+yiW:Dash <C-r>+
