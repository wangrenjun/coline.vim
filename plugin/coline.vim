scriptencoding utf-8

if exists("g:loaded_coline") || &cp
    finish
endif
let g:loaded_coline = 1
let s:keepcpo = &cpo
set cpo&vim

" Check features for statusline / tabline / title
if !has('statusline') || !has('windows') || !has('title')
    finish
endif

let g:colineTheme = get(g:, 'colineTheme', 'default')

set laststatus=2        " Always显示状态行
set showtabline=1       " Only if there are at least two tab pages
set title

function! s:Toggle(bang, ...) abort
    let g:colineTheme = get(a:, '1', g:colineTheme)
    let themeColorscheme = get(a:, '2', '')
    try
        let s:themefn = g:coline#{g:colineTheme}#theme#Init(a:bang, themeColorscheme)
    catch /^coline/
        if !a:bang
            call g:common#Throw(v:exception)
        endif
        return
    catch
        if !a:bang
            call g:common#Throw(v:exception)
            "call g:common#Throw("Couldn't find theme '" . g:colineTheme . "'")
        endif
        return
    endtry
    augroup colineSetup
        autocmd!
        autocmd ColorScheme * call s:themefn.OnColorScheme()
        autocmd BufEnter,WinEnter,BufWinEnter,CmdwinEnter * call s:themefn.OnWinEnter() " ,FileType,BufUnload,SessionLoadPost
        autocmd BufLeave,WinLeave,BufWinLeave,CmdWinLeave * call s:themefn.OnWinLeave()
        autocmd CursorHold,CursorHoldI * call s:themefn.OnHold()
    augroup END
    call s:themefn.OnStartup()
endfunction

augroup colineStartup
    autocmd!
    autocmd VimEnter * call s:Toggle(0)
augroup END

command! -nargs=* -bar -bang ColineToggle call s:Toggle(<bang>0, <f-args>)

" TODO :h guitablabel

let &cpo = s:keepcpo
unlet s:keepcpo
