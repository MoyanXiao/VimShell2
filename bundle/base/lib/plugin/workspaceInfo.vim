" File: workspaceInfo.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 20, 2013  


if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

call workspaceInfo#init()
