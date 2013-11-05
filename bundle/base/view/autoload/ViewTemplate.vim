" File: ViewTemplate.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 05, 2013

let s:viewSet={}
let s:viewBase={}

let s:viewBase.keyMap={}
let s:viewBase.title="No title"
let s:viewBase.bufNo=-1

fun! ViewTemplate#createView(viewType, viewName)
    if has_key(s:viewSet, a:viewName)
        LogNotice "Find the view ".a:viewName." don't create a new one".a:viewType
        return s:viewSet[a:viewName]
    endif
    LogNotice "Create the view ".a:viewName." with the type ".a:viewType
    try
        let s:viewSet[a:viewName]=extend(deepcopy(s:viewBase), deepcopy({a:viewName}#extension())) 
    catch /.*/
        LogError "error occurs : ".v:exception
        LogNotice "create the viewBase"
        let s:viewSet[a:viewName]=deepcopy(s:viewBase)
    endt
    return s:viewSet[a:viewName]
endf

fun! ViewTemplate#removeView(viewName)
    if has_key(s:viewSet, a:viewName)
        LogNotice "Remove the view ".a:viewName
        unlet s:viewSet[a:viewName]
    endif
    LogNotice "Can't find the view ".a:viewName
endf

fun! s:viewBase.setTitle(title)
    let self.title=a:title
endf

fun! s:viewBase.openView()
    call self.openWinPre()

    if bufexists(self.bufNo) && bufloaded(self.bufNo)
        exec self.bufNo.'bd!'
    endif

    call self.openWin()

    let self.bufNo=bufnr('%')

    call self.viewOptions()
    
    call self.viewCommands()
    
    call self.viewKeyMap()

    call self.openWinPost()
endf

fun! s:viewBase.openWinPre()
    LogDebug "viewBase openWinPre"
    
endf

fun! s:viewBase.openWinPost()
    LogDebug "viewBase openWinPost"
endf

fun! s:viewBase.openWin()
    LogDebug "viewBase openWin"
    exec 'silent pedit [viewBase] '.self.title
    wincmd P | wincmd H
endf

fun! s:viewBase.viewOptions()
    LogDebug "viewBase viewOptions"
endf

fun! s:viewBase.viewCommands()
    LogDebug "viewBase viewCommands"
endf

fun! s:viewBase.viewKeyMap()
    for [key,value] in items(self.keyMap) 
        LogDebug "key map :".key."<->".value
        exec "nnoremap <buffer> ".key." ".value
    endfor
endf
