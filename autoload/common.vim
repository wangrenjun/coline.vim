let g:common_temp_register = get(g:, 'common_temp_register', 's')

function! g:common#Error(msg) abort
    echohl ErrorMsg
    echomsg 'coline: '.a:msg
    echohl None
endfunction

function! g:common#Warn(msg) abort
    echohl WarningMsg
    echomsg 'coline: '.a:msg
    echohl None
endfunction

function! g:common#Throw(msg) abort
    let v:errmsg = 'coline: '.a:msg
    throw v:errmsg
endfunction

function! g:common#GetFilesize() " {{{
	let bytes = getfsize(expand("%:p"))
	if bytes <= 0
		return ''
	endif
	if bytes < 1024
		return bytes . 'B'
	elseif bytes < 1048576
		return (bytes / 1024) . 'kB'
    else
        return (bytes / 1048576) . 'mB'
	endif
endfunction " }}}

" a:1
"   1,          Buffer相对路径
"   2,          Buffer全路径
"   Otherwise,  Buffer文件名
" a:2, bufnr或路径
function! g:common#Bufname(which, ...)
    let arg = get(a:, '1', bufnr('%'))
    let rv = ''
    " :h filename-modifiers
    if a:which == 1
        let rv = (type(arg) == 0) ? expand('#' . arg . ':.') : fnamemodify(arg, ':.')
    elseif a:which == 2
        let rv = (type(arg) == 0) ? expand('#' . arg . ':~') : fnamemodify(arg, ':~')
    else
        let rv = (type(arg) == 0) ? expand('#' . arg . ':t') : fnamemodify(arg, ':t')
    endif
    return rv
endfunction

function! g:common#LogName()
    return exists('$LOGNAME') ? $LOGNAME : split(system('whoami'), '\n')[0]
endfunction

function! g:common#HostName()
    let host = exists('$HOSTNAME') ? $HOSTNAME : hostname()
    if empty(host)
        let host = split(system('hostname --fqdn'), '\n')[0]
    endif
    return host
endfunction

function! g:common#LocalUserAtHost()
    return g:common#LogName() . '@' . g:common#HostName()
endfunction

function! g:common#RemoteUserAtHost()
    return get(g:, 'netrw_machine', '')
endfunction

function! g:common#GetHlArgsFromHlGroup(hlgroup, ...)
    let fg      = synIDattr(hlID(a:hlgroup), 'fg')
    let bg      = synIDattr(hlID(a:hlgroup), 'bg')
    let bold    = synIDattr(hlID(a:hlgroup), 'bold') ? 'bold' : ''
    let reverse = synIDattr(hlID(a:hlgroup), 'reverse')
    if reverse
        let [ fg, bg ] = [ bg, fg ]
    endif
    return { 'fg' : fg, 'bg' : bg, 'attr' : [ bold: ] }
endfunction

function! g:common#GetSyntaxItemAtLnCol(lnum, col)
    return synIDattr(synID(a:lnum, a:col, 1), "name")
endfunction

function! g:common#CountSelectedLine()
    return line("'>") - line("'<") + 1
endfunction

function! g:common#CountSelectedColumn()
    return col("'>") - col("'<") + 1
endfunction

let g:ROWS = 0
let g:COLS = 1
let g:VCOLS = 2
function! g:common#GetVisualRange()
    let [ bnr, start_line, start_col, start_off ] = getpos('v')
    let [ bnr, cursor_line, cursor_col, cursor_off ] = getpos('.')
    let start_vcol = virtcol([ start_line, start_col, start_off ])
    let cursor_vcol = virtcol([ cursor_line, cursor_col, cursor_off ])
    let rows = abs(cursor_line - start_line) + 1
    let cols = abs(cursor_col - start_col) + 1
    let vcols = abs(cursor_vcol - start_vcol) + 1
    return [ rows, cols, vcols ]
endfunction

function! g:common#GetSelectedTextInVisualMode()
    let reg = g:common_temp_register
    execute 'let temp = @' . reg
    execute 'normal! "' . reg . 'y'
    execute 'let text = @' . reg
    execute 'let @' . reg . ' = temp'
    normal! gv
    return text
endfunction

function! g:common#GetSelectedTextInSelectMode()
    let reg = g:common_temp_register
    execute 'let temp = @' . reg
    execute "normal! \<C-C>gv\"" . reg . "y"
    execute 'let text = @' . reg
    execute 'let @' . reg . ' = temp'
    execute "normal! gv\<C-G>"
    return text
endfunction

function! g:common#CountSelectedLineInVisualAndSelectMode()
    let start_line = line('v')
    let cursor_line = line('.')
    return abs(cursor_line - start_line) + 1
endfunction

function! g:common#CountSelectedColumnInVisualAndSelectMode()
    let start_col = col('v')
    let cursor_col = col('.')
    return abs(cursor_col - start_col) + 1
endfunction

function! g:common#GetBufnrByTabnr(...)
    let tabnr = get(a:, '1', tabpagenr())
    let winnr = tabpagewinnr(tabnr)
    let bufnrlist = tabpagebuflist(tabnr)
    return bufnrlist[winnr - 1]
endfunction

function! g:common#GetBufnrByWinnr(...)
    let tabnr = tabpagenr()
    let winnr = get(a:, '1', winnr())
    let bufnrlist = tabpagebuflist(tabnr)
    return bufnrlist[winnr - 1]
endfunction

function! g:common#GetBufnrInWinOfTab(...)
    let tabnr = get(a:, '2', tabpagenr())
    let winnr = get(a:, '1', tabpagewinnr(tabnr))
    if winnr == '$' || winnr == '#'
        let winnr = tabpagewinnr(tabnr, winnr)
    endif
    let bufnrlist = tabpagebuflist(tabnr)
    return bufnrlist[winnr - 1]
endfunction

function! g:common#GetBufnrInWin(...)
    let wnr = get(a:, '1', winnr())
    if wnr == '$' || wnr == '#'
        let wnr = winnr(wnr)
    endif
    let bufnrlist = tabpagebuflist()
    return bufnrlist[wnr - 1]
endfunction

function! g:common#Log(msglist, fpath)
    call writefile(a:msglist, a:fpath, "a")
endfunction

" If trailing white space is detected its line number is returned
function! g:common#GetWSLine()
    return search('\s$', 'nw')
endfunction
