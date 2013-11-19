" File: BunbleInit.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 20, 2013
"

let g:bundle_dir=expand("<sfile>:p:h")

let s:base_dir=g:bundle_dir."/base"

for item in split(expand(s:base_dir.'/*'))
    exec "set rtp^=".item
    exec "set rtp+=".item
endfor

exec "runtime! plugin/*.vim"
exec "runtime! after/*.vim"

call LoadManager#LoadAllPlugins()
