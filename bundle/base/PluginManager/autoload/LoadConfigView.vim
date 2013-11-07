" File: LoadConfigView.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 07, 2013

let s:loadview={}
let s:loadview.keyMap={
            \'q' : ':silent bd!<CR>'
            \}

fun! LoadConfigView#extension()
    return s:loadview
endf

fun! s:loadview.viewOptions()
    setl buftype=nofile
    setl noswapfile

    setl cursorline
    setl nonu ro noma ignorecase 
    if (exists('&relativenumber')) | setl norelativenumber | endif

    setl ft=Config
    setl syntax=vim

    syn keyword vimOption loaded True
    syn keyword vimErrSetting unload False
endf
