" File: SearchManager.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 11, 2013  
"

fun! SearchManager#SearchPlugin(plname)
    return reverse(filter(s:load_scripts(0), 'v:val =~? "'.escape(a:plname, '"').'"'))
endf

func! s:fetch_scripts(to)
    let scripts_dir = fnamemodify(expand(a:to, 1), ":h")
    if !isdirectory(scripts_dir)
        call mkdir(scripts_dir, "p")
    endif
    let l:vim_scripts_json = 'http://vim-scripts.org/api/scripts.json'
    if executable("curl")
        let cmd = 'curl --fail -s -o '.shellescape(a:to).' '.l:vim_scripts_json
    elseif executable("wget")
        let temp = shellescape(tempname())
        let cmd = 'wget -q -O '.temp.' '.l:vim_scripts_json. ' && mv -f '.temp.' '.shellescape(a:to)
    else
        LogError 'Error curl or wget is not available!'
        return 1
    endif
    LogNotice cmd
    call system(cmd)
    if (0 != v:shell_error)
        LogError 'Error fetching scripts! Error code is '.string(v:shell_error)
        return v:shell_error
    endif
    return 0
endf

func! s:load_scripts(bang)
    let f = expand(g:bundle_dir.'/.vundle/script-names.vim-scripts.org.json', 1)
    if a:bang || !filereadable(f)
        if 0 != s:fetch_scripts(f)
            return []
        end
    endif
    return eval(readfile(f, 'b')[0])
endf
