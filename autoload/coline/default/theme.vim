scriptencoding utf-8

let g:coline_theme_colorscheme = get(g:, 'coline_theme_colorscheme', 'default')
let g:coline_default_show_datetime = get(g:, 'coline_default_show_datetime', 1)
let g:coline_default_show_datetime_minwidth = get(g:, 'coline_default_show_datetime_minwidth', 166)
let g:coline_default_show_localhost = get(g:, 'coline_default_show_localhost', 1)

" 1         Buffer相对路径
" 2         Buffer全路径
" Otherwise Buffer文件名
let g:coline_default_show_bufname = get(g:, 'coline_default_show_bufname', 1)

let g:coline_default_paste_indicator = get(g:, 'coline_default_paste_indicator', 'PASTE')

let g:coline_default_tabline_close_button = get(g:, 'coline_default_tabline_close_button', 'Tabs')

let g:coline_default_new_file_title = get(g:, 'coline_default_new_file_title', '[No Name]')

let g:coline_default_title_length = get(g:, 'coline_default_title_length', 50)

let g:coline_default_show_virtual_column = get(g:, 'coline_default_show_virtual_column', 0)

let g:coline_default_highlight_group_name_prefix = get(g:, 'coline_default_highlight_group_name_prefix', 'coline_default')

" 0 count bytes
" 1 count characters
let g:coline_default_show_selected_text_length_in_chars = get(g:, 'coline_default_show_selected_text_length_in_chars', 1)

let s:colorsfn = {}

function! g:coline#default#theme#Init(...) abort
    let g:coline_theme_colorscheme = (a:0 && !empty(a:1)) ? a:1 : g:coline_theme_colorscheme
    try
        let s:colorsfn = g:coline#{g:colineTheme}#colorscheme#{g:coline_theme_colorscheme}#Init()
    catch
        call g:common#Throw(v:exception)
        "call g:common#Throw("Couldn't find colorscheme '" . g:coline_theme_colorscheme . "' in theme '" . g:colineTheme . "'")
        return
    endtry
    return {
        \ 'OnStartup'       : function('s:OnStartup'),
        \ 'OnColorScheme'   : function('s:OnColorScheme'),
        \ 'OnWinEnter'      : function('s:OnWinEnter'),
        \ 'OnWinLeave'      : function('s:OnWinLeave'),
        \ 'OnHold'          : function('s:OnHold'),
        \ }
endfunction

function! s:OnStartup()
    let curwnr = winnr()
    for wnr in range(1, winnr('$'))
        call setwinvar(wnr, '&statusline', '%!g:RefreshStatusline(' . (wnr != curwnr) . ')')
        " let ls = g:RefreshStatusline(wnr != curwnr)
        " call setwinvar(0, '&statusline', ls)
    endfor
    set tabline=%!g:Tabline()
    let &titlelen=g:coline_default_title_length
    set titlestring=%<%r\ %n.\ %f\ %m%=%l/%L
endfunction

function! s:OnColorScheme()
    call s:colorsfn.Highlightings()
endfunction

function! s:OnWinEnter()
    call setwinvar(0, '&statusline', '%!g:RefreshStatusline()')
    "let ls = g:RefreshStatusline()
    "call setwinvar(0, '&statusline', ls)
endfunction

function! s:OnWinLeave()
    "call setwinvar(0, '&statusline', '%!g:RefreshStatusline(' . 1 . ')')
    let ls = g:RefreshStatusline(1)
    call setwinvar(0, '&statusline', ls)
endfunction

function! s:OnHold()
    return
endfunction

function! g:RefreshStatusline(...)
    let is_notcurrent = get(a:, '1', 0)
    let is_unmodifiable = &l:previewwindow || !&l:modifiable
    let mode = get(s:mode_mappings, mode(), s:DEFAULT_MODE)
    let modehlkey = mode[s:MODE_HLKEY_IDX]
    let ls = ''
    let lastcell = ''
    let fnlist = is_notcurrent
        \ ? s:leave_statusline_fn_list
        \ : (is_unmodifiable ? s:enter_unmodifiable_statusline_fn_list : s:enter_modifiable_statusline_fn_list)
    for fn in fnlist
        let [ curcell, Cb ] = items(fn)[0]
        let lspart = Cb(curcell, mode, is_notcurrent, is_unmodifiable)
        if !empty(lspart)
            if !empty(lastcell)
                let [ border, hlgroupname ] = s:colorsfn.GetBorderHlGroupName(modehlkey, lastcell, curcell)
                let ls .= ' '
                if !empty(hlgroupname) | let ls .= '%#' . hlgroupname . '#' | endif
                if !empty(border) | let ls .= border | endif
            endif
            let ls .= lspart
            let lastcell = curcell
        endif
    endfor
    return ls
endfunction

function! s:StatuslineMode(cellname, mode, ...)
    let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, 'mode_name')
    let ls = '%#' . hlgroupname . '#'
    let ls .= ' ' . a:mode[s:MODE_NAME_IDX]
    return ls
endfunction

function! s:StatuslineSelectRange(cellname, mode, ...)
    let ls = ''
    let mletter = mode()
    if mletter !~# '\v(v|V||s|S|)'
        return ls
    endif
    let modehlkey = a:mode[s:MODE_HLKEY_IDX]
    let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'select_range')
    let rows = g:common#CountSelectedLineInVisualAndSelectMode()
    if mletter ==# 'v'
        let text = g:common#GetSelectedTextInVisualMode()
        let cnt = g:coline_default_show_selected_text_length_in_chars ? strchars(text) : strlen(text)
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' L:' . rows . ' T:' . cnt
    elseif mletter ==# 's'
        let text = g:common#GetSelectedTextInSelectMode()
        let cnt = g:coline_default_show_selected_text_length_in_chars ? strchars(text) : strlen(text)
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' L:' . rows . ' T:' . cnt
    elseif mletter =~# '^[VS]$'
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' L:' . rows
    elseif mletter =~# '\v(|)'
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' L:' . rows . ' C:' . g:common#CountSelectedColumnInVisualAndSelectMode()
    endif
    return ls
endfunction

function! s:StatuslinePaste(cellname, mode, ...)
    let ls = ''
    if &paste
        let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, 'pasted_flag')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . g:coline_default_paste_indicator
    endif
    return ls
endfunction

function! s:StatuslineBranch(cellname, mode, ...)
    let ls = ''
    let modehlkey = a:mode[s:MODE_HLKEY_IDX]
    let branch = g:coline#GetBranch()
    if !empty(branch)
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'branch_flag')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . g:coline#unicodeSymbols.versionControlBranch
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'branch_name')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . branch
    endif
    return ls
endfunction

function! s:StatuslinePath(cellname, mode, ...)
    let is_notcurrent = get(a:, '1', 0)
    let is_unmodifiable = get(a:, '2', 0)
    let ls = ''
    let modehlkey = a:mode[s:MODE_HLKEY_IDX]
    if &readonly && !is_unmodifiable
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'locked_flag_nc' : 'locked_flag')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . g:coline#unicodeSymbols.closedPadlock
    endif
    if !is_notcurrent && g:coline_default_show_localhost
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'local_host')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . g:common#LocalUserAtHost()
    endif
    let path = g:coline#Bufname(g:coline_default_show_bufname)
    if !empty(path[0])
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'file_path_nc' : 'file_path')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . path[0] . '/'
    endif
    if !empty(path[1])
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'file_name_nc' : 'file_name')
        let ls .= '%#' . hlgroupname . '#'
        if empty(path[0]) | let ls .= ' ' | endif
        let ls .= path[1]
    endif
    if &modified || is_unmodifiable
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'modified_flag_nc' : 'modified_flag')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= is_unmodifiable ? ' -' : ' +'
    endif
    return ls
endfunction

function! s:StatuslineTag(cellname, mode, ...)
    let ls = ''
    let tag = g:coline#CurTag()
    if !empty(tag)
        let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, 'cur_tag')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . tag
    endif
    return ls
endfunction

function! s:StatuslineDatetime(cellname, mode, ...)
    let ls = ''
    if g:coline_default_show_datetime && winwidth(0) > g:coline_default_show_datetime_minwidth
        let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, 'date_time')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' %<%{strftime("%Y-%m-%d %H:%M:%S")}'
    endif
    return ls
endfunction

function! s:StatuslineLinefill(cellname, mode, ...)
    let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname)
    return ' %#' . hlgroupname . '#%='
endfunction

function! s:StatuslineFormat(cellname, mode, ...)
    let ls = ''
    if !empty(&fileformat)
        let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, 'file_format')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' %{&fileformat}'
    endif
    return ls
endfunction

function! s:StatuslineEncoding(cellname, mode, ...)
    let ls = ''
    if !empty(&fileencoding)
        let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, 'file_encoding')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= " %{&fileencoding}%{&bomb ? ' BOM' : ''}"
    endif
    return ls
endfunction

function! s:StatuslineType(cellname, mode, ...)
    let ls = ''
    if !empty(&filetype)
        let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, 'file_type')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' %{&filetype}'
    endif
    return ls
endfunction

function! s:StatuslinePercent(cellname, mode, ...)
    let is_notcurrent = get(a:, '1', 0)
    let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname, is_notcurrent ? 'scroll_percent_nc' : 'scroll_percent')
    let ls = '%#' . hlgroupname . '#'
    let ls .= ' %3p%%'
    return ls
endfunction

function! s:StatuslineLineCol(cellname, mode, ...)
    let is_notcurrent = get(a:, '1', 0)
    let modehlkey = a:mode[s:MODE_HLKEY_IDX]
    let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'cursor_line_nc' : 'cursor_line')
    let ls = '%#' . hlgroupname . '#'
    let ls .= ' %l'
    let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'cursor_column_nc' : 'cursor_column')
    let ls .= '%#' . hlgroupname . '#'
    let ls .= ':' . (g:coline_default_show_virtual_column ? '%v' : '%c')
    if !is_notcurrent
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'byte_number')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' %o'
    endif
    return ls
endfunction

function! s:StatuslineTabWinBufnr(cellname, mode, ...)
    let modehlkey = a:mode[s:MODE_HLKEY_IDX]
    let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'tab_number')
    let ls = '%#' . hlgroupname . '#'
    let ls .= ' T:%{tabpagenr()}'
    let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'win_number')
    let ls .= '%#' . hlgroupname . '#'
    let ls .= ' W:%{winnr()}'
    let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, 'buf_number')
    let ls .= '%#' . hlgroupname . '#'
    let ls .= ' B:%n'
    return ls
endfunction

let s:enter_modifiable_statusline_fn_list = [
    \ { 'statusline_mode'                       : function('s:StatuslineMode')          },
    \ { 'statusline_select_range'               : function('s:StatuslineSelectRange')   },
    \ { 'statusline_paste'                      : function('s:StatuslinePaste')         },
    \ { 'statusline_branch'                     : function('s:StatuslineBranch')        },
    \ { 'statusline_path'                       : function('s:StatuslinePath')          },
    \ { 'statusline_tag'                        : function('s:StatuslineTag')           },
    \ { 'statusline_datetime'                   : function('s:StatuslineDatetime')      },
    \ { 'statusline_linefill'                   : function('s:StatuslineLinefill')      },
    \ { 'statusline_format'                     : function('s:StatuslineFormat')        },
    \ { 'statusline_encoding'                   : function('s:StatuslineEncoding')      },
    \ { 'statusline_type'                       : function('s:StatuslineType')          },
    \ { 'statusline_percent'                    : function('s:StatuslinePercent')       },
    \ { 'statusline_linecol'                    : function('s:StatuslineLineCol')       },
    \ { 'statusline_tabwinbufnr'                : function('s:StatuslineTabWinBufnr')   },
    \ ]
    
let s:enter_unmodifiable_statusline_fn_list = [
    \ { 'statusline_unmodifiable_select_range'  : function('s:StatuslineSelectRange')   },
    \ { 'statusline_unmodifiable_path'          : function('s:StatuslinePath')          },
    \ { 'statusline_unmodifiable_linefill'      : function('s:StatuslineLinefill')      },
    \ { 'statusline_unmodifiable_percent'       : function('s:StatuslinePercent')       },
    \ { 'statusline_unmodifiable_linecol'       : function('s:StatuslineLineCol')       },
    \ ]

let s:leave_statusline_fn_list = [
    \ { 'statusline_notcurrent_path'            : function('s:StatuslinePath')          },
    \ { 'statusline_notcurrent_linefill'        : function('s:StatuslineLinefill')      },
    \ { 'statusline_notcurrent_percent'         : function('s:StatuslinePercent')       },
    \ { 'statusline_notcurrent_linecol'         : function('s:StatuslineLineCol')       },
    \ ]

function! g:Tabline()
    " :h setting-tabline
    let mode = get(s:mode_mappings, mode(), s:DEFAULT_MODE)
    let modehlkey = mode[s:MODE_HLKEY_IDX]
    let ls = ''
    let lastcell = ''
    let tabnum = tabpagenr('$')
    for i in range(tabnum)
        let tabnr = i + 1
        let winnr = tabpagewinnr(tabnr)
        let bufnrlist = tabpagebuflist(tabnr)
        let bufnr = bufnrlist[winnr - 1]
        let curcell =  tabnr == tabpagenr() ? 'tabline_active_label' : 'tabline_noactive_label'
        let lspart = s:TablineLabel(curcell, mode, tabnr, winnr, bufnr)
        if !empty(lspart)
            if !empty(lastcell)
                let [ border, hlgroupname ] = s:colorsfn.GetBorderHlGroupName(modehlkey, lastcell, curcell)
                let ls .= ' '
                if !empty(hlgroupname) | let ls .= '%#' . hlgroupname . '#' | endif
                if !empty(border) | let ls .= border | endif
            endif
            let ls .= lspart
            let lastcell = curcell
        endif
    endfor
    
    let curcell = 'tabline_linefill'
    let lspart = s:TablineLinefill(curcell, mode, tabnr, winnr, bufnr)
    let [ border, hlgroupname ] = s:colorsfn.GetBorderHlGroupName(modehlkey, lastcell, curcell)
    let ls .= ' '
    if !empty(hlgroupname) | let ls .= '%#' . hlgroupname . '#' | endif
    if !empty(border) | let ls .= border | endif
    let ls .= lspart
    let lastcell = curcell
    
    if tabnum > 1
        let curcell = 'tabline_button'
        let lspart = s:TablineButton(curcell, mode, tabnr, winnr, bufnr)
        let [ border, hlgroupname ] = s:colorsfn.GetBorderHlGroupName(modehlkey, lastcell, curcell)
        let ls .= ' '
        if !empty(hlgroupname) | let ls .= '%#' . hlgroupname . '#' | endif
        if !empty(border) | let ls .= border | endif
        let ls .= lspart
    endif
    return ls
endfunction

function! s:TablineLabel(cellname, mode, ...)
    let tabnr = get(a:, '1', tabpagenr())
    let winnr = get(a:, '2', winnr())
    let bufnr = get(a:, '3', bufnr('%'))
    let is_readonly = getbufvar(bufnr, '&readonly')
    let is_unmodifiable = getbufvar(bufnr, '&previewwindow') || !getbufvar(bufnr, '&modifiable')
    let is_modified = getbufvar(bufnr, '&modified')
    let is_notcurrent = tabnr == tabpagenr() ? 0 : 1
    let ls = ''
    let modehlkey = a:mode[s:MODE_HLKEY_IDX]
    if is_readonly && !is_unmodifiable
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'locked_flag_nc' : 'locked_flag')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= ' ' . g:coline#unicodeSymbols.closedPadlock
    endif
    let path = g:common#Bufname(g:coline_default_show_bufname)
    if empty(path)
        let path = g:coline_default_new_file_title
    endif
    let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'file_path_nc' : 'file_path')
    let ls .= '%#' . hlgroupname . '#'
    let ls .= ' ' . path . '/'
    if is_modified || is_unmodifiable
        let hlgroupname = s:colorsfn.GetHlGroupName(modehlkey, a:cellname, is_notcurrent ? 'modified_flag_nc' : 'modified_flag')
        let ls .= '%#' . hlgroupname . '#'
        let ls .= is_unmodifiable ? ' -' : ' +'
    endif
    return ls
endfunction

function! s:TablineLinefill(cellname, mode, ...)
    let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname)
    return ' %#' . hlgroupname . '#%T'
endfunction

function! s:TablineButton(cellname, mode, ...)
    let hlgroupname = s:colorsfn.GetHlGroupName(a:mode[s:MODE_HLKEY_IDX], a:cellname)
    let ls = '%=%#' . hlgroupname . '#%999X' . g:coline_default_tabline_close_button
    return ls
endfunction

let s:MODE_NAME_IDX = 0
let s:MODE_HLKEY_IDX = 1
let s:DEFAULT_MODE = [ 'NORMAL', 'normal' ]
" :h mode()
let s:mode_mappings = {
    \ 'n'           : [ 'NORMAL',   'normal'    ],
    \ 'i'           : [ 'INSERT',   'insert'    ],
    \ 'c'           : [ 'NORMAL',   'normal'    ],
    \ 'cv'          : [ 'VIMEX',    'normal'    ],
    \ 'ce'          : [ 'NORMALEX', 'normal'    ],
    \ 'v'           : [ 'VISUAL',   'visual'    ],
    \ 'V'           : [ 'VLINE',    'visual'    ],
    \ "\<C-V>"      : [ 'VBLOCK',   'visual'    ],
    \ 's'           : [ 'SELECT',   'select'    ],
    \ 'S'           : [ 'SLINE',    'select'    ],
    \ "\<C-S>"      : [ 'SBLOCK',   'select'    ],
    \ 'R'           : [ 'REPLACE',  'replace'   ],
    \ 'RV'          : [ 'VREPLACE', 'replace'   ],
    \ 'no'          : [ 'PENDING',  'normal'    ],
    \ }
