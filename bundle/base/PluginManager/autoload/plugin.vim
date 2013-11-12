" File: plugin.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 06, 2013
"
"
if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

"
"s:plugin_dict = {
"            \suitename:{
"            \      pluginname:{attributes}
"            \         ...
"            \          } 
"            \ ...
"            \}

let s:plugin_dict={}
let s:bundle_dir=[g:bundle_dir]

fun! plugin#dirworker()
    let rtplist=split(&rtp, ',')
    for item in s:bundle_dir
        LogDebug "bundle_dir item is ".item
        let suitelist=split(expand(item.'/*'),'\n')
        for snpath in suitelist
            if !isdirectory(snpath)
                continue
            endif
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
                let plgset['name']=pn
                let plgset['uri']=''
                let plgset['name_spec']=''
                let plgset['suite']=sn
                let plgset['path']=pnpath
                let plgset['filelist']=split(expand(pnpath.'/**'))
                let plgset['load']=(index(rtplist, pnpath)<0)?'unload':'loaded'
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
                unlet value2
            endfor
            unlet value1
        endfor
    endfor
    return retstr
endf

fun! plugin#listPluginStatus()
    let retstr = []
    for [key, value] in items(s:plugin_dict)
        let retstr = retstr + ["SuiteName:".key."\tEnableStatus:".value["enable"]]
        for [key1, value1] in items(value)
            if key1 == 'enable'
                unlet value1
                continue
            endif
            let retstr = retstr + ["\tStatus:".value1["load"]."\tenable:".value1["enable"]."\tPluginName:".key1]
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
        return {}
    endif
    try
        return s:plugin_dict[a:1][a:2]
    catch
        LogError "could not find the plugin info ".a:1."->".a:2
        return {}
    endtry
endf

