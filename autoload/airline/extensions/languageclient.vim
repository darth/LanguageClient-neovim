" MIT License. Copyright (c) 2013-2018 Vadim Alimguzhin
" vim: et ts=2 sts=2 sw=2

scriptencoding utf-8

let s:spc = g:airline_symbols.space

let s:error_symbol = get(g:, 'airline#extensions#languageclient#error_symbol', 'E:')
let s:warning_symbol = get(g:, 'airline#extensions#languageclient#warning_symbol', 'W:')
let s:show_line_numbers = get(g:, 'airline#extensions#languageclient#show_line_numbers', 0)

function! s:airline_languageclient_count(cnt, symbol)
  return a:cnt ? a:symbol. a:cnt : ''
endfunction

function s:airline_languageclient_get_problems()
  return LanguageClient#getCurrentDiagnostics()
endfunction

function! s:airline_languageclient_get_line_number(cnt, type) abort
  if a:cnt == 0
    return ''
  endif

  let problem_type = (a:type ==# 'error') ? 'E' : 'W'
  let problems     = s:airline_languageclient_get_problems()

  call filter(problems, 'v:val.type is# problem_type')

  if empty(problems)
    return ''
  endif

  let open_lnum_symbol  = get(g:, 'airline#extensions#languageclient#open_lnum_symbol', '(L')
  let close_lnum_symbol = get(g:, 'airline#extensions#languageclient#close_lnum_symbol', ')')

  return open_lnum_symbol . problems[0].lnum . close_lnum_symbol
endfunction

function! airline#extensions#languageclient#get(type)
  if !exists(':LanguageClientStart')
    return ''
  endif

  let is_err = a:type ==# 'error'
  let problem_type = is_err ? 'E' : 'W'
  let symbol = is_err ? s:error_symbol : s:warning_symbol

  let problems = s:airline_languageclient_get_problems()
  call filter(problems, 'v:val.type is# problem_type')
  let num = len(problems)

  if s:show_line_numbers == 1
    return s:airline_languageclient_count(num, symbol) . <sid>airline_languageclient_get_line_number(num, a:type)
  else
    return s:airline_languageclient_count(num, symbol)
  endif
endfunction

function! airline#extensions#languageclient#get_warning()
  return airline#extensions#languageclient#get('warning')
endfunction

function! airline#extensions#languageclient#get_error()
  return airline#extensions#languageclient#get('error')
endfunction

function! airline#extensions#languageclient#status()
  if has_key(g:LanguageClient_serverCommands, &ft)
    let msg = 'LSP:' . s:spc
    if g:LanguageClient_running[&ft]
      let msg .= ''
    else
      let msg .= ''
    endif
    return s:spc.g:airline_right_alt_sep.s:spc.msg.s:spc
  else
    return ''
  endif
endfunction

function! airline#extensions#languageclient#init(ext)
  call a:ext.add_statusline_func('airline#extensions#languageclient#apply')
  augroup airline_languageclient
    autocmd!
    autocmd User LanguageClientDiagnosticsSet
    \ if get(g:, 'airline_skip_empty_sections', 0) |
    \   AirlineRefresh |
    \ endif |
  augroup END
endfunction

function! airline#extensions#languageclient#apply(...)
  let w:airline_section_x = get(w:, 'airline_section_x', g:airline_section_x)
  let w:airline_section_x .= '%{airline#extensions#languageclient#status()}'
  let w:airline_section_error = get(w:, 'airline_section_error', g:airline_section_error)
  let w:airline_section_error .= '%{airline#extensions#languageclient#get_error()}'
  let w:airline_section_warning = get(w:, 'airline_section_warning', g:airline_section_warning)
  let w:airline_section_warning .= '%{airline#extensions#languageclient#get_warning()}'
endfunction
