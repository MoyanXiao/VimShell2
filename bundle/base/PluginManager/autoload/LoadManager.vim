" File: LoadManager.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 07, 2013
"

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

let s:loadview={}

fun! LoadManager#doConfig()
    let s:loadview=ViewTemplate#createView("LoadConfigView", "PluginConfigLoad")
    call s:loadview.setContent(plugin#listPluginStatus())
    call s:loadview.openView()
endf

fun! LoadManager#RefreshConfig()
    call s:loadview.updateContent(plugin#listPluginStatus())
endf

fun! LoadManager#LoadAllPlugins()
    LogNotice "Starting to load the plugins..."
    call plugin#dirworker()
    let plugins=plugin#findPlugin()
    for [key, value] in items(plugins)
        if value["enable"] == "False"
            unlet value
            continue
        endif
        for [key1, value1] in items(value)
            if key1 == "enable"
                unlet value1
                continue
            endif
            if value1["enable"] == "True"
                LogNotice "Loading the plugin ".key1
                call s:rtp_add(value1["path"])
                let value1["load"]="loaded"
            endif
            unlet value1
        endfor
        unlet value
    endfor
    exec "runtime! plugin/*.vim"
    exec "runtime! after/*.vim"
endf

fun! LoadManager#LoadSuite(suitename)
    LogNotice "Starting to enable and load the suite ".a:suitename
    let plugins=plugin#findPlugin()
    if !has_key(plugins, a:suitename)
        LogError "Could not find the plugin suite:".a:suitename
        return
    endif

    plugins[a:suitename]["enable"]="True"

    for [key, value] in items(plugins[a:suitename])
        if key == "enable"
            unlet value
            continue
        endif

        if value["enable"] == "True"
            LogNotice "Loading the plugin ".key
            call s:rtp_add(value["path"])
            let value["load"]="loaded"
        endif
        unlet value
    endfor 
endf

fun! LoadManager#LoadPlugin(...)
    if a:0 == 0 || a:0 > 2
        return
    endif

    if a:0 == 1
        let plugin=plugin#findPlugin(a:1)
        if empty(plugin)
            LogError "Could not find the plugin:".a:1
            return
        endif
        LogNotice "Load and enable the plugin:".a:1
        let plugin["load"]="loaded"
        let plugin["enable"]="True"
        call s:rtp_add(plugin["path"])
        exec "runtime! plugin/*.vim"
        exec "runtime! after/*.vim"
    endif

    if a:0 == 2
        let plugin=plugin#findPlugin(a:1,a:2)
        if empty(plugin)
            LogError "could not find the plugin ".a:2." in the suite ".a:1
            return
        endif
        LogNotice "Load and enable the plugin:".a:1
        let plugin["load"]="loaded"
        let plugin["enable"]="True"
        call s:rtp_add(plugin["path"])
        exec "runtime! plugin/*.vim"
        exec "runtime! after/*.vim"
    endif
endf

fun! LoadManager#DisableSuite(suitename)
    let suites=plugin#findPlugin()
    if !has_key(suites, a:suitename)
        LogError "Could not find the suite ".a:suitename
        return
    endif
    LogNotice "Disable the plugin : ".a:suitename
    let suites[a:suitename]["enable"]="False"
endf

fun! LoadManager#DisablePlugin(...)
    if a:0 == 0 || a:0 > 2
        return
    endif

    if a:0 == 1
        let plugin=plugin#findPlugin(a:1)
        if empty(plugin)
            LogError "Could not find the plugin:".a:1
            return
        endif
        LogNotice "Disable the plugin ".a:1
        let plugin["enable"]="False"
        return
    endif

    if a:0 == 2
        let plugin=plugin#findPlugin(a:1, a:2)
        if empty(plugin)
            LogError "Could not find the plugin:".a:2." in the suite ".a:1
            return
        endif
        LogNotice "Disable the plugin ".a:2." in the suite ".a:1
        let plugin["enable"]="False"
        return
    endif
endf

fun! s:rtp_add(path)
    exec "set rtp^=".fnameescape(a:path)
    exec "set rtp+=".fnameescape(a:path)
endf
