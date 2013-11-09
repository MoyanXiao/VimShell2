function! common#guardScriptLoading(path, vimVersion, exprs)
    let loadedVarName = 'g:loaded_' . substitute(join(split(a:path,'/')[-3:], '_'), '\W', '_', 'g')
    if exists(loadedVarName)
        return 0
    elseif a:vimVersion > 0 && a:vimVersion > v:version
        echoerr a:path . ' requires Vim version ' . string(a:vimVersion * s:VERSION_FACTOR)
        return 0
    endif
    for expr in a:exprs
        if !eval(expr)
            echoerr a:path . ' requires: ' . expr
            return 0                                                                                                                                                                                                                              
        endif
    endfor
    let {loadedVarName} = 1
    return 1
endfunction

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif
