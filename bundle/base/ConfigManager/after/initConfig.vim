" File: initConfig.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 22, 2013  

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

" TODO to define the config select logic
exec "runtime! Configs/default/*.vim"
