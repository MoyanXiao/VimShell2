" File: LoadManager.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 07, 2013
"

let s:loadview={}

fun! LoadManager#doConfig()
    let s:loadview=ViewTemplate#createView("LoadConfigView", "PluginConfigLoad")
    call s:loadview.setTitle("Plugin Load Configuration")
    call s:loadview.setContent(plugin#listPluginStatus())
    call s:loadview.openView()
endf

fun! LoadManager#LoadAllPlugins()
    LogNotice "Starting to load the plugins..."
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

fun! s:rtp_add(path)
    exec "set rtp^=".fnameescape(a:path)
    exec "set rtp+=".fnameescape(a:path)
endf
