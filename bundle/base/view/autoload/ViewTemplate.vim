" File: ViewTemplate.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 05, 2013

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

let s:viewSet={}

" interface to create and remove view
fun! ViewTemplate#createView(viewType, viewName)
    if has_key(s:viewSet, a:viewName)
        LogNotice "Find the view ".a:viewName." don't create a new one ".a:viewType
        return s:viewSet[a:viewName]
    endif
    LogNotice "Create the view ".a:viewName." with the type ".a:viewType
    try
        let s:viewSet[a:viewName]=extend(deepcopy(s:viewBase), deepcopy({a:viewType}#extension())) 
    catch /.*/
        LogError "error occurs : ".v:exception
        LogNotice "create the viewBase"
        let s:viewSet[a:viewName]=deepcopy(s:viewBase)
    endtry
    return s:viewSet[a:viewName]
endf

fun! ViewTemplate#removeView(viewName)
    if has_key(s:viewSet, a:viewName)
        LogNotice "Remove the view ".a:viewName
        unlet s:viewSet[a:viewName]
    endif
    LogNotice "Can't find the view ".a:viewName
endf

" viewBase is the base class
let s:viewBase={}
let s:viewBase.keyMap={}
let s:viewBase.bufNo=-1
let s:viewBase.title="No title"
let s:viewBase.content=""

" Set the title of the view 
" MUST be set before openView()
fun! s:viewBase.setTitle(title)
    let self.title=a:title
endf

" Set the content of the view 
" MUST be set before openView()
fun! s:viewBase.setContent(content)
    let self.content=a:content
endf

" openView is to use start the view
fun! s:viewBase.openView()
    call self.openWinPre()
    if bufexists(self.bufNo) && bufloaded(self.bufNo)
        exec self.bufNo.'bd!'
    endif
    call self.openWin()
    let self.bufNo=bufnr('%')
    call self.viewContent()
    call self.viewOptions()
    call self.viewCommands()
    call self.viewKeyMap()
    call self.openWinPost()
endf

fun! s:viewBase.viewKeyMap()
    for [key,value] in items(self.keyMap) 
        LogDebug "key map :".key."<->".value
        exec "nnoremap <buffer> ".key." ".value
    endfor
endf

fun! s:viewBase.openWin()
    LogDebug "viewBase openWin"
    exec 'silent pedit [view] '.self.title
    wincmd P | wincmd H
endf

fun! s:viewBase.viewContent()
    if !(bufexists(self.bufNo) && bufloaded(self.bufNo))
        LogError "Don't support change the unopened config view"
        return
    endif
    if self.bufNo != bufnr('%')
        LogError "The file you are trying to update is not the config view!!!!!Dangerous!!!!return to the config"
        exec bufwinnr(self.bufNo).'wincmd w'
    endif
    setl modifiable
    normal ggdG
    LogDebug "add the content: ".string(self.content)
    call append(0, self.content)
    setl nomodifiable
endf

fun! s:viewBase.check()
    if !(bufexists(self.bufNo) && bufloaded(self.bufNo))
        LogError "Don't support change the unopened config view"
        return -1
    endif
    return 0
endf

fun! s:viewBase.updateContent(content)
    LogDebug "viewBase updateContent"
    call self.setContent(a:content)
    call self.viewContent()
endf

" To overwrite in the extension
fun! s:viewBase.openWinPre()
    LogDebug "viewBase openWinPre"
endf

" To overwrite in the extension
fun! s:viewBase.openWinPost()
    LogDebug "viewBase openWinPost"
endf

" To overwrite in the extension
fun! s:viewBase.viewOptions()
    LogDebug "viewBase viewOptions"
endf

" To overwrite in the extension
fun! s:viewBase.viewCommands()
    LogDebug "viewBase viewCommands"
endf

