setlocal ts=4 sw=4 sts=4 et

autocmd Filetype java inoremap <C-q><C-q> System.out.println();<Left><Left>
autocmd Filetype java inoremap <C-q><C-w> System.out.println()<Left>
autocmd Filetype java inoremap <C-q><C-a> public static void main(String[] args){<CR>}<Up><End><CR>
