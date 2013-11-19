" File: workspaceInfo.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 10, 2013
"

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif


let s:workspace="./.workspace"
let g:workspaceInfoFile=s:workspace."/workspace_info"
let g:workspaceInfo={}
let s:sep='<->'

fun! workspaceInfo#init()
    if !isdirectory(s:workspace) || !filereadable(g:workspaceInfoFile)
        return
    endif

    for line in readfile(g:workspaceInfoFile)
        if match(line, s:sep) < 0
            continue
        endif
        let tmplist = split(line, s:sep)
        exec "let g:workspaceInfo[".string(tmplist[0])."]=".tmplist[1]
    endfor

    for key in keys(g:workspaceInfo)
        exec "let ".key."=".string(g:workspaceInfo[key])
    endfor
endf

fun! workspaceInfo#create()
    silent! execute "!mkdir -p ".s:workspace
    silent! execute "!touch ".g:workspaceInfoFile
    silent! execute "!chmod a+w ".g:workspaceInfoFile
    LogNotice "Create the work space Info"
endf

fun! workspaceInfo#saveInfo(key, value)
    if has_key(g:workspaceInfo, a:key)
        LogNotice "Replace the exists info key:".a:key
    endif
    let g:workspaceInfo[a:key]=a:value
    call s:sync()
endf

fun! workspaceInfo#getInfo(key, default)
    if has_key(g:workspaceInfo, a:key)
        return g:workspaceInfo[a:key]
    endif
    LogError "Could not get the info key:".a:key
    return a:default
endf

fun! s:sync()
    if !isdirectory(s:workspace) || !filereadable(g:workspaceInfoFile)
        return
    endif
    let fl=[]
    for key in keys(g:workspaceInfo)
        call add(fl, key.s:sep.g:workspaceInfo[key])
    endfor
    call writefile(fl, g:workspaceInfoFile)
endf

