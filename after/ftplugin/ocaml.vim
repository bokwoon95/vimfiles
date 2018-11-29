let maplocalleader = "\<C-c>"
setlocal ts=2 sw=2 sts=2 et
setlocal commentstring=(*\ %s\ *)

"Merlin bindings
nnoremap <buffer> <C-c><C-t> :MerlinTypeOf<CR>
xnoremap <buffer> <C-c><C-t> :MerlinTypeOfSel<CR>
nnoremap <buffer> <C-c><C-d> :MerlinDocument<CR>
