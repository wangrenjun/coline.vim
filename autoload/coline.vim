scriptencoding utf-8

" \uE0A0
" \uE0A2
" \uE0B0
" \uE0B1
" \uE0B2
" \uE0B3
let g:coline#unicodeSymbols = {
    \ 'versionControlBranch'        : '',
    \ 'closedPadlock'               : '',
    \ 'rightwardsBlackArrowhead'    : '',
    \ 'rightwardsArrowhead'         : '',
    \ 'leftwardsBlackArrowhead'     : '',
    \ 'leftwardsArrowhead'          : '',
    \ }

" More 256 Terminal colors http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
" 256 colors name https://jonasjacek.github.io/colors/
if !has('gui_running') && &t_Co >= 256
    " Console colors
    let g:coline#term = 'cterm'
    let g:coline#colors = {
        \ 'black'           : 16,
        \ 'white'           : 231,
        \
        \ 'darkestgreen'    : 22,
        \ 'darkgreen'       : 28,
        \ 'mediumgreen'     : 70,
        \ 'brightgreen'     : 148,
        \
        \ 'darkestcyan'     : 23,
        \ 'mediumcyan'      : 117,
        \
        \ 'darkestblue'     : 24,
        \ 'darkblue'        : 31,
        \
        \ 'darkestred'      : 52,
        \ 'darkred'         : 88,
        \ 'mediumred'       : 124,
        \ 'brightred'       : 160,
        \ 'brightestred'    : 196,
        \
        \ 'darkestpurple'   : 55,
        \ 'mediumpurple'    : 98,
        \ 'brightpurple'    : 189,
        \
        \ 'darkorange'      : 94,
        \ 'mediumorange'    : 166,
        \ 'brightorange'    : 208,
        \ 'brightestorange' : 214,
        \
        \ 'gray0'           : 233,
        \ 'gray1'           : 235,
        \ 'gray2'           : 236,
        \ 'gray3'           : 239,
        \ 'gray4'           : 240,
        \ 'gray5'           : 241,
        \ 'gray6'           : 244,
        \ 'gray7'           : 245,
        \ 'gray8'           : 247,
        \ 'gray9'           : 250,
        \ 'gray10'          : 252,
        \
        \ 'yellow'          : 136,
        \ 'orange'          : 166,
        \ 'red'             : 160,
        \ 'magenta'         : 125,
        \ 'violet'          : 61,
        \ 'blue'            : 33,
        \ 'cyan'            : 37,
        \ 'green'           : 64,
        \ }
elseif has('gui_running')
    " Graphical colors
    let g:coline#term = 'gui'
    let g:coline#colors = {
        \ 'black'           : '#000000',
        \ 'white'           : '#ffffff',
        \
        \ 'darkestgreen'    : '#005f00',
        \ 'darkgreen'       : '#008700',
        \ 'mediumgreen'     : '#5faf00',
        \ 'brightgreen'     : '#afdf00',
        \
        \ 'darkestcyan'     : '#005f5f',
        \ 'mediumcyan'      : '#87dfff',
        \
        \ 'darkestblue'     : '#005f87',
        \ 'darkblue'        : '#0087af',
        \
        \ 'darkestred'      : '#5f0000',
        \ 'darkred'         : '#870000',
        \ 'mediumred'       : '#af0000',
        \ 'brightred'       : '#df0000',
        \ 'brightestred'    : '#ff0000',
        \
        \ 'darkestpurple'   : '#5f00af',
        \ 'mediumpurple'    : '#875fdf',
        \ 'brightpurple'    : '#dfdfff',
        \
        \ 'darkorange'      : '#ff8c00',
        \ 'mediumorange'    : '#cd6600',
        \ 'brightorange'    : '#ff8700',
        \ 'brightestorange' : '#ffaf00',
        \
        \ 'gray0'           : '#121212',
        \ 'gray1'           : '#262626',
        \ 'gray2'           : '#303030',
        \ 'gray3'           : '#4e4e4e',
        \ 'gray4'           : '#585858',
        \ 'gray5'           : '#606060',
        \ 'gray6'           : '#808080',
        \ 'gray7'           : '#8a8a8a',
        \ 'gray8'           : '#9e9e9e',
        \ 'gray9'           : '#bcbcbc',
        \ 'gray10'          : '#d0d0d0',
        \
        \ 'yellow'          : '#b58900',
        \ 'orange'          : '#cb4b16',
        \ 'red'             : '#dc322f',
        \ 'magenta'         : '#d33682',
        \ 'violet'          : '#6c71c4',
        \ 'blue'            : '#268bd2',
        \ 'cyan'            : '#2aa198',
        \ 'green'           : '#859900',
        \ }
else
    call g:common#Throw("Unsupported this color setting")
endif

" a:which
"   1           Buffer相对路径
"   2           Buffer全路径
"   Otherwise   Buffer文件名
" a:1, bufnr
function! g:coline#Bufname(which, ...)
    let arg = get(a:, '1', bufnr('%'))
    let path = {}
    let dir = ''
    " :h filename-modifiers
    if a:which == 1
        let dir = expand('#' . arg . ':.:h')
    elseif a:which == 2
        let dir = expand('#' . arg . ':~:h')
    endif
    return [ dir, expand('#' . arg . ':t') ]
endfunction

let s:has_fugitive = exists('*fugitive#head')
let s:has_lawrencium = exists('*lawrencium#statusline')
let s:has_hgrev = exists('*HGRev')
let s:has_tagbar = exists('*tagbar#currenttag')
let s:has_capslock = exists('*CapsLockStatusline')

function! g:coline#GetBranch()
    let status = s:GitBranch()
    if empty(status)
        let status = s:HgBranch()
    endif
    return status
endfunction

" https://github.com/tpope/vim-capslock
function! g:coline#CapsLock()
    let cl = ''
    if s:has_capslock
        let cl = CapsLockStatusline('Caps')
    endif
    return cl
endfunction

function! g:coline#CurTag()
    let tag = ''
    if s:has_tagbar
        let tag = tagbar#currenttag('[%s]', '')
    endif
    return tag
endfunction

function! s:GitPs1()
    let status = ''
    let rv = split(system('echo $(type -t __git_ps1)'), '\n')
    if !empty(rv) && rv[0] ==# 'function'
        let ps1 = split(system('echo $(__git_ps1 "%s")'), '\n')
        let status = empty(ps1) ? '' : ps1[0]
    endif
    return status
endfunction

function! s:GitBranch()
    if s:has_fugitive
        let status = fugitive#head(7)
    else
        let status = s:GitPs1()
    endif
    return status
endfunction

" https://github.com/ludovicchabant/vim-lawrencium
" https://github.com/vim-scripts/hgrev
function! s:HgBranch()
    let rev = ''
    if s:has_lawrencium
        let rev = lawrencium#statusline()
    elseif s:has_hgrev
        let rev = HGRev()
    endif
    return rev
endfunction
