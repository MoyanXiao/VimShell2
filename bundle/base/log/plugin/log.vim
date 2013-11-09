" File: log.vim
" Author: Moyan Xiao
" Description:      
" Last Modified: November 09, 2013
"

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

com! -nargs=1 LogDebug call log#debug(<args>)
com! -nargs=1 LogNotice call log#notice(<args>)
com! -nargs=1 LogError call log#error(<args>)
com! -nargs=1 LogLevel call log#level(<args>)
com! -nargs=0 LogPrint call log#print()
