" File: log.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 04, 2013

let s:logBuf=[]
let s:loglvl=1

" Debug log interface
fun! log#debug(msg)
    if s:loglvl < 3
        return
    endif
    call s:format(a:msg, "DEBUG")
endf

" Notice log interface
fun! log#notice(msg)
    if s:loglvl < 2
        return
    endif
    call s:format(a:msg, "INFO")
endf

" Error log interface
fun! log#error(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl NONE
    if s:loglvl < 1
        return
    endif
    call s:format(a:msg, "ERROR")
endf

" save log to a file
fun! log#savelog(filename)
    " TODO save to file
endf

" print the log this runtime
fun! log#print()
    " code
    echo join(s:logBuf, "\n")
endf

fun! s:format(str, lvl)
    let fmt = '%m.%d,%y %H:%M:%S'
    let str = join(split(expand("<sfile>"),'\.\.')[0:-3], '->')
    call add(s:logBuf,'['.str.']['.a:lvl.']['.strftime(fmt).'] '.a:str)
endf

" Modify the log level
fun! log#level(lvl)
    if index([0,1,2,3], a:lvl) == -1 
        call log#error("unknown level value ".a:lvl.", please select 1 from 0,1,2,3")
        return
    endif
    call log#notice("Change the log level to ".(["NONE","ERROR","NOTICE","DEBUG"][a:lvl]))
    let s:loglvl=a:lvl
endf
