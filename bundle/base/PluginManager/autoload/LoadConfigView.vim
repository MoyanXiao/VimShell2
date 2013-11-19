" File: LoadConfigView.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 07, 2013

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

let s:loadview={}
let s:loadview.keyMap={
            \'q' : ':silent bd!<CR>',
            \'l' : ':LoadP<CR>',
            \'i' : ':InstallP<CR>',
            \'D' : ':DisableP<CR>'
            \}

fun! LoadConfigView#extension()
    return s:loadview
endf

fun! s:loadview.viewOptions()
    setl buftype=nofile
    setl noswapfile
    setlocal bufhidden=delete

    setl cursorline
    setl nonu ro noma ignorecase 
    if (exists('&relativenumber')) | setl norelativenumber | endif

    setl ft=Config
    setl syntax=vim

    syn keyword vimOption loaded True
    syn keyword vimErrSetting unload False
endf

fun! s:loadview.openWinPre()
    call self.setTitle("Plugin Load Configuration")
endf

fun! s:loadview.viewCommands()
    com! -buffer -nargs=0 LoadP call s:loadPlugin()
    com! -buffer -nargs=0 DisableP call s:disablePlugin()
    com! -buffer -nargs=0 InstallP call s:searchPlugin()
endf

fun! s:loadPlugin()
    let configItem=getline(".")
    let update=0
    if match(configItem, "SuiteName") > -1
        if match(configItem, "True") > -1
            return
        else
            call LoadManager#LoadSuite(s:getSuiteName(configItem))
            let update=1
        endif
    endif

    if match(configItem, "PluginName") > -1
        if match(configItem, "loaded") > -1
            return
        else
            call LoadManager#LoadPlugin(s:getPluginName(configItem))
            let update=1
        endif
    endif

    if update == 1
        call LoadManager#RefreshConfig()
    endif
endf

fun! s:disablePlugin()
    let configItem=getline(".")
    let update=0
    if match(configItem, "SuiteName") > -1 
        if match(configItem, "False") > -1
            return
        else
            let ps=s:getSuiteName(configItem)
            LogNotice "Disable the plugin suite:".ps
            call LoadManager#DisableSuite(ps)
            let update=1
        endif
    endif

    if match(configItem, "PluginName") > -1
        if match(configItem, "False") > -1
            return
        else
            let pn=s:getPluginName(configItem)
            LogNotice "Disable the plugin:".pn
            call LoadManager#DisablePlugin(pn)
            let update=1
        endif
    endif

    if update == 1
        call LoadManager#RefreshConfig()
    endif

endf

fun! s:getSuiteName(str)
    return split(filter(split(a:str, '\t'), 'v:val =~ "SuiteName"')[0], ':')[1]
endf

fun! s:getPluginName(str)
    return split(filter(split(a:str, '\t'), 'v:val =~ "PluginName"')[0], ':')[1]
endf

fun! s:searchPlugin()
    let bar=InputBarTemplate#getInputBar()
    let bar["CompleteHook"]=function("SearchManager#SearchPlugin")
    let bar["FinishHook"]=function("InstallManager#install")
    let bar["RefreshHook"]=function("LoadManager#RefreshConfig")
    let bar["suite"]="tmp"
    let curlineNum=line('.')
    let curline=getline(curlineNum)
    while curlineNum > 0
        if match(curline, "SuiteName") > -1
            let bar["suite"] = s:getSuiteName(curline)
            break
        endif
        let curlineNum -= 1
    endwhile
    call bar.openBar()
endf
