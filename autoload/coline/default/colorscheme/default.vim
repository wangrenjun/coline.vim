scriptencoding utf-8

function! g:coline#default#colorscheme#default#Init()
    return {
        \ 'Highlightings'           : function('s:Highlightings'),
        \ 'GetHlGroupName'          : function('s:GetHlGroupName'),
        \ 'GetBorderHlGroupName'    : function('s:GetBorderHlGroupName'),
        \ }
endfunction

function! s:Highlightings(...)
    return
endfunction

function! s:GetHlGroupName(modehlkey, cellname, ...)
    let itemname = get(a:, '1', '')
    return s:CommandHlGroup(s:GetHlArgs(a:modehlkey, a:cellname, itemname))
endfunction

function! s:GetBorderHlGroupName(modehlkey, fcellname, bcellname)
    let border = get(s:cells_border, a:fcellname, '')
    let fargs = s:GetHlArgs(a:modehlkey, a:fcellname)
    let bargs = s:GetHlArgs(a:modehlkey, a:bcellname)
    if border ==# '>'
        if fargs.bg !=# bargs.bg
            return [ g:coline#unicodeSymbols.rightwardsBlackArrowhead, s:CommandHlGroup({ 'fg' : fargs.bg, 'bg' : bargs.bg }) ]
        else
            return [ g:coline#unicodeSymbols.rightwardsArrowhead, '' ]
        endif
    elseif border ==# '<'
        if fargs.bg !=# bargs.bg
            return [ g:coline#unicodeSymbols.leftwardsBlackArrowhead, s:CommandHlGroup({ 'fg' : bargs.bg, 'bg' : fargs.bg }) ]
        else
            return [ g:coline#unicodeSymbols.leftwardsArrowhead, '' ]
        endif
    endif
    return [ border, '' ]
endfunction

function s:CommandHlGroup(hlargs, ...)
    let clear = get(a:, '1', 0)
    let fg = get(a:hlargs, 'fg', '')
    let bg = get(a:hlargs, 'bg', '')
    let attr = get(a:hlargs, 'attr', [])
    let hlgroupname = g:coline_default_highlight_group_name_prefix . printf('_%s_%s_%s', fg, bg, join(attr, '_'))
    if has_key(s:highlighted_groups, hlgroupname)
        return hlgroupname
    endif
    if clear | execute 'highlight clear ' . hlgroupname | endif
    let hlcommand = 'highlight ' . hlgroupname
    if !empty(fg)   | let hlcommand .= ' ' . g:coline#term . 'fg=' . g:coline#colors[fg] | endif
    if !empty(bg)   | let hlcommand .= ' ' . g:coline#term . 'bg=' . g:coline#colors[bg] | endif
    if !empty(attr) | let hlcommand .= ' ' . g:coline#term . '=' . join(attr, ',') | endif
    execute hlcommand
    let s:highlighted_groups[hlgroupname] = 1
    return hlgroupname
endfunction

let s:DEFAULT_HLKEY = 'normal'

function! s:GetHlArgs(modehlkey, cellname, ...)
    let itemname = get(a:, '1', '')
    let dic = get(s:cells_color, a:cellname, {})
    let cellargs = get(dic, a:modehlkey, {})
    if empty(cellargs) && a:modehlkey !=? s:DEFAULT_HLKEY | let cellargs = get(dic, s:DEFAULT_HLKEY, {}) | endif
    if empty(itemname) | return cellargs | endif
    let dic = get(s:items_color, itemname, {})
    let itemargs = get(dic, a:modehlkey, {})
    if empty(itemargs) && a:modehlkey !=? s:DEFAULT_HLKEY | let itemargs = get(dic, s:DEFAULT_HLKEY, {}) | endif
    return extend(cellargs, itemargs)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""

let s:statusline_mode = {
    \ 'normal'  : { 'bg' : 'brightgreen'},
    \ 'insert'  : { 'bg' : 'white' },
    \ 'visual'  : { 'bg' : 'brightorange' },
    \ 'select'  : { 'bg' : 'gray5' },
    \ 'replace' : { 'bg' : 'brightred' },
    \ }

let s:statusline_select_range = {
    \ 'visual'  : { 'bg' : 'darkorange' },
    \ 'select'  : { 'bg' : 'darkorange' },
    \ }

let s:statusline_paste = {
    \ 'normal'  : { 'bg' : 'mediumorange' },
    \ }

let s:statusline_branch = {
    \ 'normal'  : { 'bg' : 'gray4' },
    \ 'insert'  : { 'bg' : 'darkblue' },
    \ }

let s:statusline_path = {
    \ 'normal'  : { 'bg' : 'gray4' },
    \ 'insert'  : { 'bg' : 'darkblue' },
    \ }

let s:statusline_tag = {
    \ 'normal'  : { 'bg' : 'gray2' },
    \ 'insert'  : { 'bg' : 'darkestblue' },
    \ }

let s:statusline_datetime = {
    \ 'normal'  : { 'bg' : 'gray2' },
    \ 'insert'  : { 'bg' : 'darkestblue' },
    \ }

let s:statusline_linefill = {
    \ 'normal'  : { 'bg' : 'gray2' },
    \ 'insert'  : { 'bg' : 'darkestblue' },
    \ }

let s:statusline_format = {
    \ 'normal'  : { 'bg' : 'gray2' },
    \ 'insert'  : { 'bg' : 'darkestblue' },
    \ }
    
let s:statusline_encoding = {
    \ 'normal'  : { 'bg' : 'gray2' },
    \ 'insert'  : { 'bg' : 'darkestblue' },
    \ }
    
let s:statusline_type = {
    \ 'normal'  : { 'bg' : 'gray2' },
    \ 'insert'  : { 'bg' : 'darkestblue' },
    \ }

let s:statusline_percent = {
    \ 'normal'  : { 'bg' : 'gray4' },
    \ 'insert'  : { 'bg' : 'darkblue' },
    \ }

let s:statusline_linecol = {
    \ 'normal'  : { 'bg' : 'gray10' },
    \ 'insert'  : { 'bg' : 'mediumcyan' },
    \ }

let s:statusline_tabwinbufnr = {
    \ 'normal'  : { 'bg' : 'gray10' },
    \ 'insert'  : { 'bg' : 'mediumcyan' },
    \ }

let s:statusline_unmodifiable_select_range = s:statusline_select_range

let s:statusline_unmodifiable_path = {
    \ 'normal'  : s:statusline_path.normal,
    \ }

let s:statusline_unmodifiable_linefill = {
    \ 'normal' : s:statusline_linefill.normal,
    \ }

let s:statusline_unmodifiable_percent = {
    \ 'normal'  : s:statusline_percent.normal,
    \ }

let s:statusline_unmodifiable_linecol = {
    \ 'normal'  : s:statusline_linecol.normal,
    \ }

let s:statusline_notcurrent_path = {
    \ 'normal' : { 'bg' : 'gray5' },
    \ }

let s:statusline_notcurrent_linefill = {
    \ 'normal' : s:statusline_linefill.normal,
    \ }

let s:statusline_notcurrent_percent = {
    \ 'normal' : { 'bg' : 'gray2' },
    \ }

let s:statusline_notcurrent_linecol = {
    \ 'normal' : { 'bg' : 'gray4' },
    \ }

let s:tabline_active_label = {
    \ 'normal'  : { 'bg' : 'gray4' },
    \ 'insert'  : { 'bg' : 'darkblue' },
    \ }

let s:tabline_noactive_label = {
    \ 'normal'  : { 'bg' : 'gray2' },
    \ 'insert'  : { 'bg' : 'darkestblue' },
    \ }

let s:tabline_linefill = s:statusline_linefill

let s:tabline_button = {
    \ 'normal'  : { 'bg' : 'gray10' },
    \ 'insert'  : { 'bg' : 'mediumcyan' },
    \ }

let s:cells_color = {
    \ 'statusline_mode'                         : s:statusline_mode,
    \ 'statusline_select_range'                 : s:statusline_select_range,
    \ 'statusline_paste'                        : s:statusline_paste,
    \ 'statusline_branch'                       : s:statusline_branch,
    \ 'statusline_path'                         : s:statusline_path,
    \ 'statusline_tag'                          : s:statusline_tag,
    \ 'statusline_datetime'                     : s:statusline_datetime,
    \ 'statusline_linefill'                     : s:statusline_linefill,
    \ 'statusline_format'                       : s:statusline_format,
    \ 'statusline_encoding'                     : s:statusline_encoding,
    \ 'statusline_type'                         : s:statusline_type,
    \ 'statusline_percent'                      : s:statusline_percent,
    \ 'statusline_linecol'                      : s:statusline_linecol,
    \ 'statusline_tabwinbufnr'                  : s:statusline_tabwinbufnr,
    \ 'statusline_unmodifiable_select_range'    : s:statusline_unmodifiable_select_range,
    \ 'statusline_unmodifiable_path'            : s:statusline_unmodifiable_path,
    \ 'statusline_unmodifiable_linefill'        : s:statusline_unmodifiable_linefill,
    \ 'statusline_unmodifiable_percent'         : s:statusline_unmodifiable_percent,
    \ 'statusline_unmodifiable_linecol'         : s:statusline_unmodifiable_linecol,
    \ 'statusline_notcurrent_path'              : s:statusline_notcurrent_path,
    \ 'statusline_notcurrent_linefill'          : s:statusline_notcurrent_linefill,
    \ 'statusline_notcurrent_percent'           : s:statusline_notcurrent_percent,
    \ 'statusline_notcurrent_linecol'           : s:statusline_notcurrent_linecol,
    \ 'tabline_active_label'                    : s:tabline_active_label,
    \ 'tabline_noactive_label'                  : s:tabline_noactive_label,
    \ 'tabline_linefill'                        : s:tabline_linefill,
    \ 'tabline_button'                          : s:tabline_button,
    \ }

""""""""""""""""""""""""""""""""""""""""""""""

let s:mode_name = {
    \ 'normal'      : { 'fg' : 'darkestgreen',  'attr' : [ 'bold' ] },
    \ 'insert'      : { 'fg' : 'darkestcyan',   'attr' : [ 'bold' ] },
    \ 'visual'      : { 'fg' : 'darkred',       'attr' : [ 'bold' ] },
    \ 'select'      : { 'fg' : 'white',         'attr' : [ 'bold' ] },
    \ 'replace'     : { 'fg' : 'white',         'attr' : [ 'bold' ] },
    \ }

let s:select_range = {
    \ 'normal'      : { 'fg' : 'brightestorange', 'attr' : [ 'bold' ] },
    \ }

let s:pasted_flag = {
    \ 'normal'      : { 'fg' : 'white',         'attr' : [ 'bold' ] },
    \ }

let s:branch_flag = {
    \ 'normal'      : { 'fg' : 'gray9' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:branch_name = {
    \ 'normal'      : { 'fg' : 'gray9' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:locked_flag = {
    \ 'normal'      : { 'fg' : 'brightestred' },
    \ }

let s:local_host = {
    \ 'normal'      : { 'fg' : 'gray10',        'attr' : [ 'bold' ] },
    \ 'insert'      : { 'fg' : 'mediumcyan',    'attr' : [ 'bold' ] },
    \ }

let s:file_path = {
    \ 'normal'      : { 'fg' : 'gray10',        'attr' : [ 'bold' ] },
    \ 'insert'      : { 'fg' : 'mediumcyan',    'attr' : [ 'bold' ] },
    \ }

let s:file_name = {
    \ 'normal'      : { 'fg' : 'white',         'attr' : [ 'bold' ] },
    \ 'insert'      : { 'fg' : 'white',         'attr' : [ 'bold' ] },
    \ }

let s:modified_flag = {
    \ 'normal'      : { 'fg' : 'yellow' },
    \ }

let s:cur_tag = {
    \ 'normal'      : { 'fg' : 'gray8' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:date_time = {
    \ 'normal'      : { 'fg' : 'gray8' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:file_format = {
    \ 'normal'      : { 'fg' : 'gray8' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:file_encoding = {
    \ 'normal'      : { 'fg' : 'gray8' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:file_type = {
    \ 'normal'      : { 'fg' : 'gray8' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:scroll_percent = {
    \ 'normal'      : { 'fg' : 'gray9' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:cursor_line = {
    \ 'normal'      : { 'fg' : 'black' },
    \ 'insert'      : { 'fg' : 'darkestcyan' },
    \ }

let s:cursor_column = {
    \ 'normal'      : { 'fg' : 'darkestgreen' },
    \ 'insert'      : { 'fg' : 'darkestgreen' },
    \ }

let s:byte_number = {
    \ 'normal'      : { 'fg' : 'gray2' },
    \ 'insert'      : { 'fg' : 'gray2' },
    \ }

let s:tab_number = {
    \ 'normal'      : { 'fg' : 'gray4' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:win_number = {
    \ 'normal'      : { 'fg' : 'gray4' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }

let s:buf_number = {
    \ 'normal'      : { 'fg' : 'gray4' },
    \ 'insert'      : { 'fg' : 'mediumcyan' },
    \ }
    
let s:locked_flag_nc = {
    \ 'normal'      : { 'fg' : 'darkestred' },
    \ }

let s:file_path_nc = {
    \ 'normal'      : { 'fg' : 'gray5',         'attr' : [ 'bold' ] },
    \ }

let s:file_name_nc = {
    \ 'normal'      : { 'fg' : 'gray8',         'attr' : [ 'bold' ] },
    \ }

let s:modified_flag_nc = {
    \ 'normal'      : { 'fg' : 'yellow' },
    \ }

let s:scroll_percent_nc = {
    \ 'normal'      : { 'fg' : 'gray5' },
    \ }

let s:cursor_line_nc = {
    \ 'normal'      : { 'fg' : 'black',         'attr' : [ 'bold' ] },
    \ }

let s:cursor_column_nc = {
    \ 'normal'      : { 'fg' : 'darkestgreen',  'attr' : [ 'bold' ] },
    \ }

let s:close_button = {
    \ 'normal'      : { 'fg' : 'black',         'attr' : [ 'bold' ] },
    \ 'insert'      : { 'fg' : 'darkblue',      'attr' : [ 'bold' ] },
    \ }

let s:items_color = {
    \ 'mode_name'           : s:mode_name,
    \ 'select_range'        : s:select_range,
    \ 'pasted_flag'         : s:pasted_flag,
    \ 'branch_flag'         : s:branch_flag,
    \ 'branch_name'         : s:branch_name,
    \ 'locked_flag'         : s:locked_flag,
    \ 'local_host'          : s:local_host,
    \ 'file_path'           : s:file_path,
    \ 'file_name'           : s:file_name,
    \ 'modified_flag'       : s:modified_flag,
    \ 'cur_tag'             : s:cur_tag,
    \ 'date_time'           : s:date_time,
    \ 'file_format'         : s:file_format,
    \ 'file_encoding'       : s:file_encoding,
    \ 'file_type'           : s:file_type,
    \ 'scroll_percent'      : s:scroll_percent,
    \ 'cursor_line'         : s:cursor_line,
    \ 'cursor_column'       : s:cursor_column,
    \ 'byte_number'         : s:byte_number,
    \ 'tab_number'          : s:tab_number,
    \ 'win_number'          : s:win_number,
    \ 'buf_number'          : s:buf_number,
    \ 'locked_flag_nc'      : s:locked_flag_nc,
    \ 'file_path_nc'        : s:file_path_nc,
    \ 'file_name_nc'        : s:file_name_nc,
    \ 'modified_flag_nc'    : s:modified_flag_nc,
    \ 'scroll_percent_nc'   : s:scroll_percent_nc,
    \ 'cursor_line_nc'      : s:cursor_line_nc,
    \ 'cursor_column_nc'    : s:cursor_column_nc,
    \ 'close_button'        : s:close_button,
    \ }

let s:cells_border = {
    \ 'statusline_mode'                     : '>',
    \ 'statusline_select_range'             : '>',
    \ 'statusline_paste'                    : '>',
    \ 'statusline_branch'                   : '>',
    \ 'statusline_path'                     : '>',
    \ 'statusline_tag'                      : '>',
    \ 'statusline_format'                   : '<',
    \ 'statusline_encoding'                 : '<',
    \ 'statusline_type'                     : '<',
    \ 'statusline_percent'                  : '<',
    \ 'statusline_linecol'                  : '<',
    \ 'statusline_unmodifiable_select_range': '>',
    \ 'statusline_unmodifiable_path'        : '>',
    \ 'statusline_unmodifiable_percent'     : '<',
    \ 'statusline_notcurrent_path'          : '>',
    \ 'statusline_notcurrent_percent'       : '<',
    \ 'tabline_active_label'                : '>',
    \ 'tabline_noactive_label'              : '>',
    \ 'tabline_linefill'                    : '<',
    \ }

let s:highlighted_groups = {}
