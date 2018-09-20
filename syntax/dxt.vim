" Vim syntax file
" Language: Debugger Text
" Maintainer: Bok Woon
" Latest Revision: 9 August 2018

if exists("b:current_syntax")
  finish
endif

syn keyword dxtBoolean TRUE FALSE
  hi dxtBoolean gui=bold guifg=red
syn keyword dxtFlowControl if else for
  hi dxtFlowControl guifg=maroon
syn keyword dxtFuncExit return
  hi dxtFuncExit guifg=maroon

" syn match dxtFuncEnter '!.\*().\*!'
  " hi dxtFuncEnter gui=bold guifg=green
syn match dxtParameterDeclaration '[^\ ,()]\+:[^\ ,()]\+'
  hi dxtParameterDeclaration gui=underline guifg=blue

syn region dxtStringv1 start="'" end="'" contained
  hi def link dxtStringv1 String
syn region dxtStringv2 start='"' end='"' contained
  hi def link dxtStringv2 String

syn match dxtBoilerplate "#.*$"
  hi dxtBoilerplate guifg=Grey54

"syntax region dxtString start=/\v"/ skip=/\v\\./ end=/\v"/
syntax region dxtString start=+"+ skip=/\v\\./ end=+"+ end=+$+
highlight link dxtString String
