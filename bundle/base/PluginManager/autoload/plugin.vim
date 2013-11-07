" File: plugin.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 06, 2013
"
"
"s:plugin_dict = {
"            \suitename:{
"            \      pluginname:{attributes}
"            \         ...
"            \          } 
"            \ ...
"            \}

let s:plugin_dict={}
let s:bundle_dir=['/home/Source/vimplugin/VimShell2/bundle']

fun! plugin#dirworker()
    for item in s:bundle_dir
        LogDebug "bundle_dir item is ".item
        let suitelist=split(expand(item.'/*'),'\n')
        for snpath in suitelist
            let sn=fnamemodify(snpath,':t')
            LogDebug "add suite ".sn." in the bundle_dir ".item
            let s:plugin_dict[sn]={'enable' : 'True'}
            let pluginlist=split(expand(snpath.'/*'))
            for pnpath in pluginlist
                if !isdirectory(pnpath)
                    continue
                endif
                let pn=fnamemodify(pnpath,':t')
                LogDebug "add plugin ".pn." in the suite ".sn
                let suiteset=s:plugin_dict[sn]
                let suiteset[pn]={}
                let plgset=suiteset[pn]
                let plgset['path']=pnpath
                let plgset['load']='unload'
                let plgset['enable']='True'
                " TODO other init
            endfor
        endfor
    endfor
    LogDebug plugin#listPlugins()
endf

fun! plugin#listPlugins()
    let retstr = ""
    for [key, value] in items(s:plugin_dict)
        let retstr = retstr."Suite Name : ".key."\n"
        for [key1, value1] in items(value)
            if key1 == 'enable'
                unlet value1
                continue
            endif
            let retstr = retstr."\tPlugin ".key1." with attributes:"."\n"
            for [key2,value2] in items(value1)
                let retstr = retstr."\t\t".key2.":".string(value2)."\n"
            endfor
            unlet value1
        endfor
    endfor
    return retstr
endf

fun! plugin#listPluginStatus()
    let retstr = []
    for [key, value] in items(s:plugin_dict)
        let retstr = retstr + ["Suite Name : ".key.", enable status: ".value["enable"]]
        for [key1, value1] in items(value)
            if key1 == 'enable'
                unlet value1
                continue
            endif
            let retstr = retstr + ["\t"."Status:".value1["load"].",\tenable:".value1["enable"]."\t\tName:".key1]
            unlet value1
        endfor
    endfor
    return retstr
endf

fun! plugin#findPlugin(...)
    if a:0 == 0
        return s:plugin_dict
    endif
    if a:0 == 1
        for [key, value] in items(s:plugin_dict)
            if has_key(value, a:1)
                return value[a:1]
            endif
        endfor
        return null
    endif
    try
        return s:plugin_dict[a:1][a:2]
    catch
        LogError "could not find the plugin info ".a:1."->".a:2
        return null
    endtry
endf

