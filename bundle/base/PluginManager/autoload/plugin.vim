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
            let s:plugin_dict[sn]={}
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
            let retstr = retstr."\tPlugin ".key1." with attributes:"."\n"
            for [key2,value2] in items(value1)
                let retstr = retstr."\t\t".key2.":".string(value2)."\n"
            endfor
        endfor
    endfor
    return retstr
endf
