" File: InstallManager.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 18, 2013

if !common#guardScriptLoading(expand("<sfile>:p"), 702, [])
    finish
endif

let s:updated_bundles=[]

fun! InstallManager#install(suite, name)
    LogNotice "Install ".a:name." in the suite ".a:suite
    if !s:check_suite(a:suite)
        return
    endif

    let pldict=s:parse_name(substitute(a:name,"['".'"]\+','','g'))
    let pldict['suite']=a:suite
    let pldict['path']=expand(g:bundle_dir).'/'.a:suite.'/'.pldict['name']
    LogDebug "Create new plugin info:".string(pldict)
    let ret=s:sync(1,pldict)
    if ret =~ 'error'
        return
    endif
    let rtplist=split(&rtp, ',')
    let pldict['filelist']=split(expand(pldict['path'].'/**'))
    let pldict['load']=(index(rtplist,pldict['path'])<0)?'unload':'loaded'
    let pldict['enable']='True'
    call s:update_plugin(a:suite, pldict)
    call s:create_changelog()
endf

func! s:check_suite(suite)
    if !exists("g:bundle_dir")
        return 0
    endif
    if isdirectory(expand(g:bundle_dir).'/'.a:suite)
        LogNotice "Find a directory:".expand(g:bundle_dir).'/'.a:suite
        return 1
    endif
    let action=common#Confirm("To create a new suite".a:suite."?", ["Yes", "No"])

    if action =~ "No"
        LogNotice "Don't create a new directory"
        return 0
    endif

    if action =~ "Yes"
        LogNotice "Create a new directory:".expand(g:bundle_dir).'/'.a:suite
        exec "!mkdir -p ".expand(g:bundle_dir).'/'.a:suite
        if (0 != v:shell_error)
            LogError 'Error creating the directory!'
            return 0
        endif
        return 1
    endif
endf

func! s:create_changelog() abort
    let tmp=log#level(3)
    for bundle_data in s:updated_bundles
        let initial_sha = bundle_data[0]
        let updated_sha = bundle_data[1]
        let bundle      = bundle_data[2]
        let cmd = 'cd '.shellescape(bundle.path()).
                    \              ' && git log --pretty=format:"%s   %an, %ar" --graph '.
                    \               initial_sha.'..'.updated_sha
        let updates = system(cmd)
        LogNotice 'Updated Bundle: '.bundle
        if bundle.uri =~ "https://github.com"
            LogNotice 'Compare at: '.bundle.uri[0:-5].'/compare/'.initial_sha.'...'.updated_sha)
        endif
        for update in split(updates, '\n')
            let update = substitute(update, '\s\+$', '', '')
            LogNotice '  '.update
        endfor
    endfor
    call log#level(tmp)
endf


func! s:sync(bang, bundle) abort
    echo "Sync the plugin ".a:bundle.name
    let git_dir = expand(a:bundle.path.'/.git/', 1)
    if isdirectory(git_dir) || filereadable(expand(a:bundle.path.'/.git', 1))
        if !(a:bang) | return 'todate' | endif
        let cmd = 'cd '.shellescape(a:bundle.path).' && git pull && git submodule update --init --recursive'

        let get_current_sha = 'cd '.shellescape(a:bundle.path).' && git rev-parse HEAD'
        let initial_sha = system(get_current_sha)[0:15]
    else
        let cmd = 'git clone --recursive '.shellescape(a:bundle.uri).' '.shellescape(a:bundle.path)
        let initial_sha = ''
    endif

    let out = system(cmd)
    redraw
    echo "Sync the plugin ".a:bundle.name."........DONE"
    LogNotice 'Bundle '.a:bundle.name_spec
    LogNotice '$ '.cmd
    LogNotice '> '.out

    if 0 != v:shell_error
        return 'error'
    end

    if empty(initial_sha)
        return 'new'
    endif

    let updated_sha = system(get_current_sha)[0:15]

    if initial_sha == updated_sha
        return 'todate'
    endif

    call add(s:updated_bundles, [initial_sha, updated_sha, a:bundle])
    return 'updated'
endf

func! s:parse_name(arg)
    let arg = a:arg
    let git_proto = exists('g:vundle_default_git_proto') ? g:vundle_default_git_proto : 'https'
    if arg =~? '^\s*\(gh\|github\):\S\+'
                \  || arg =~? '^[a-z0-9][a-z0-9-]*/[^/]\+$'
        let uri = git_proto.'://github.com/'.split(arg, ':')[-1]
        if uri !~? '\.git$'
            let uri .= '.git'
        endif
        let name = substitute(split(uri,'\/')[-1], '\.git\s*$','','i')
    elseif arg =~? '^\s*\(git@\|git://\)\S\+' 
                \   || arg =~? '\(file\|https\?\)://'
                \   || arg =~? '\.git\s*$'
        let uri = arg
        let name = split( substitute(uri,'/\?\.git\s*$','','i') ,'\/')[-1]
    else
        let name = arg
        let uri  = git_proto.'://github.com/vim-scripts/'.name.'.git'
    endif
    let name = substitute(name,'\..*$','','g') 

    return {'name': name, 'uri': uri, 'name_spec': arg }
endf

func! s:update_plugin(suite, plugin)
    LogNotice "update the plugin:".a:plugin.name." in the suite:".a:suite.""
    let pInfo=plugin#findPlugin()
    if !exists("pInfo[a:suite]")
        LogDebug "Don't exists the suite:".a:suite.", create a new one"
        let pInfo[a:suite]={'enable':'True'}
        let pInfo[a:suite][a:plugin.name]=a:plugin
    else
        LogDebug "Exists the suite:".a:suite
        let pInfo[a:suite][a:plugin.name]=a:plugin
    endif
endf
