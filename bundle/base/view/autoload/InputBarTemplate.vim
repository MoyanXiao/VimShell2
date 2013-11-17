" File: InputBarTemplate.vim
" Author: Moyan Xiao
" Description: 
" Last Modified: November 17, 2013  
"


let s:inputBar={}
let s:inputBar['prompt'] = "Input Value:"
let s:inputBar['result'] = ""

fun! InputBarTemplate#createInputBar()
    " code
endf

fun! InputBarTemplate#getInputBar()
    return s:inputBar
endf

fun! s:inputBar.getPrompt()
    return self.prompt
endf

fun! s:inputBar.openBar()
    LogDebug "Enter the openBar..."
    exec "1new"
    setlocal buflisted
    setlocal noswapfile
    setlocal bufhidden=delete
    setlocal modifiable
    setlocal noreadonly
    setlocal nonumber
    setlocal buftype=nofile
    call setline(1,self.getPrompt())
    aug inputBarLocal
        autocmd!
        autocmd CursorMovedI <buffer> call InputBarTemplate#getInputBar().onCursorMovedI()
        autocmd InsertLeave <buffer> nested call InputBarTemplate#getInputBar().onInsertLeave()
    aug END
    if exists(':AcpLock')                                                                                           
        AcpLock
    elseif exists(':AutoComplPopLock')
        AutoComplPopLock
    endif

    for [key, func] in [
                \ ['<CR>', 'onCr()'],
                \ ["<BS>", 'onBs()'],
                \]
        LogDebug "Key is ".key.", func is ".func
        call s:defineKeymap(key, func)
    endfor
    call feedkeys('A', 'n')
    LogDebug "Leave the openBar..."
endf

fun! s:inputBar.closeBar()
    " code
    if exists(':AcpUnlock')
        AcpUnlock
    elseif exists(':AutoComplPopUnlock')
        AutoComplPopUnlock
    endif
    exec ":q"
endf

fun! s:inputBar.onCursorMovedI()
    if !self.existsPrompt(getline('.'))
        call setline('.', self.restorePrompt(getline('.')))
        call feedkeys("\<End>", 'n')
    elseif col('.') <= len(self.getPrompt())
        " if the cursor is moved before command prompt
        call feedkeys(repeat("\<Right>", len(self.getPrompt()) - col('.') + 1), 'n')
    endif
endf

fun! s:inputBar.onInsertLeave()
    call self.closeBar()
endf

fun! s:inputBar.onCr()
    if pumvisible()
        call feedkeys(printf("\<C-y>\<C-r>=InputBarTemplate#getInputBar().onCr() ? '' : ''\<CR>"
                    \              ), 'n')
        return
    endif
    let self.result=self.removePrompt(getline('.'))
    call feedkeys("\<Esc>", 'n') " stopinsert behavior is strange...
endf

fun! s:inputBar.onBs()
    call feedkeys((pumvisible() ? "\<C-e>\<BS>" : "\<BS>"), 'n')
endf

function s:inputBar.existsPrompt(line)
    return  strlen(a:line) >= strlen(self.getPrompt()) &&
                \ a:line[:strlen(self.getPrompt()) -1] ==# self.getPrompt()
endfunction

"
function s:inputBar.removePrompt(line)
    return a:line[(self.existsPrompt(a:line) ? strlen(self.getPrompt()) : 0):]
endfunction

"
function s:inputBar.restorePrompt(line)
    let i = 0
    while i < len(self.getPrompt()) && i < len(a:line) && self.getPrompt()[i] ==# a:line[i]
        let i += 1
    endwhile
    return self.getPrompt() . a:line[i : ]
endfunction

fun! s:defineKeymap(key, func)
    let cmds= printf(
                \'inoremap <buffer> %s <C-R>=InputBarTemplate#getInputBar().%s ? "" :""<CR>',
                \a:key, a:func)
    LogDebug cmds
    exec cmds
endf

