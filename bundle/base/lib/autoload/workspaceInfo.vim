" File: workspaceInfo.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 10, 2013
"

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif


let s:workspace="./.workspace"
let s:workspaceInfoFile=s:workspace."/workspace_info"
let s:workspaceInfo={}
let s:sep='<->'

fun! workspaceInfo#init()
    if !isdirectory(s:workspace) || !filereadable(s:workspaceInfoFile)
        return
    endif

    for line in readfile(s:workspaceInfoFile)
        if match(line, s:sep) < 0
            continue
        endif
        let tmplist = split(line, s:sep)
        exec "let s:workspaceInfo[".string(tmplist[0])."]=".string(tmplist[1])
    endfor

    for key in keys(s:workspaceInfo)
        LogDebug "Load workspace info key:".key
        exec "let ".key."=".string(s:workspaceInfo[key])
    endfor
endf

fun! workspaceInfo#create()
    silent! execute "!mkdir -p ".s:workspace
    silent! execute "!touch ".s:workspaceInfoFile
    silent! execute "!chmod a+w ".s:workspaceInfoFile
    LogNotice "Create the work space Info"
endf

fun! workspaceInfo#saveInfo(key, value)
    if has_key(s:workspaceInfo, a:key)
        LogNotice "Replace the exists info key:".a:key
    endif
    let s:workspaceInfo[a:key]=a:value
    call s:sync()
endf

fun! workspaceInfo#getInfo(key, default)
    if has_key(s:workspaceInfo, a:key)
        return s:workspaceInfo[a:key]
    endif
    LogError "Could not get the info key:".a:key
    return a:default
endf

fun! s:sync()
    if !isdirectory(s:workspace) || !filereadable(s:workspaceInfoFile)
        return
    endif
    let fl=[]
    for key in keys(s:workspaceInfo)
        call add(fl, key.s:sep.s:workspaceInfo[key])
    endfor
    call writefile(fl, s:workspaceInfoFile)
endf

