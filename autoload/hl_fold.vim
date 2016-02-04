scriptencoding utf-8
let s:last_cursor_moved = reltime()

function! hl_fold#toggle()
  if g:hl_fold_enabled
    call hl_fold#disable()
  else
    call hl_fold#enable()
  endif
endfunction

function! hl_fold#enable()
  augroup hl_fold
    autocmd!
    exec 'autocmd FileType' g:hl_fold_filetypes 'call hl_fold#enable_buffer()'
  augroup END
  doautoall hl_fold FileType
endfunction

function! hl_fold#disable()
  augroup hl_fold
    autocmd!
    autocmd User * call hl_fold#hide()
  augroup END
  doautoall hl_fold User
  autocmd! hl_fold User *
endfunction

function! hl_fold#enable_buffer()
  let g:hl_fold_enabled = 1
  augroup hl_fold
    autocmd CursorMoved <buffer> call hl_fold#show_lazy()
    autocmd CursorHold,CursorHoldI,InsertEnter,InsertLeave <buffer> call hl_fold#show()
  augroup END
  call hl_fold#show()
endfunction

function! hl_fold#disable_buffer()
  let g:hl_fold_enabled = 0
  augroup hl_fold
    autocmd!
  augroup END
  call hl_fold#hide()
endfunction

function! hl_fold#show_lazy()
  let hold = str2float(reltimestr(reltime(s:last_cursor_moved)))
  if hold > g:hl_fold_cursor_hold
    call hl_fold#show()
  endif
  let s:last_cursor_moved = reltime()
endfunction

function! hl_fold#show()
  " find fold level edges and highlight them
  let initial_line = line('.')
  let start_line = s:find_fold_edge(initial_line, -1)
  let end_line = s:find_fold_edge(initial_line, +1)

  call s:update_signs(start_line, end_line)
endfunction

function! hl_fold#hide()
  " remove signs
  call s:update_signs(0, 0)
endfunction

function! s:find_fold_edge(initial_line, increment)
  " find the edge of a fold level, starting at a:initial_line and
  " traversing in the direction given by a:increment
  let line = copy(a:initial_line)
  let initial_level = foldlevel(a:initial_line)
  while initial_level > 0 && foldlevel(line) >= initial_level
    let line += a:increment
  endwhile
  return line
endfunction

function! s:update_signs(start_line, end_line)
  " update the old signs to the new signs
  let buffer = bufnr('%')

  if !exists('b:hl_fold_signs')
    let b:hl_fold_lines = []
  endif

  let old_fold = len(b:hl_fold_lines) > 1
  let new_fold = a:end_line > a:start_line

  " move the start sign
  if new_fold || (old_fold && a:start_line != b:hl_fold_lines[0])
    if old_fold
      call s:unplace_sign(s:start_sign_id(), buffer)
    endif
    if new_fold
      call s:place_sign(s:start_sign_id(), buffer, a:start_line, 'HlFoldStart')
    endif
  endif

  " move the end sign
  if new_fold || (old_fold && a:end_line != b:hl_fold_lines[-1])
    if old_fold
      call s:unplace_sign(s:end_sign_id(), buffer)
    endif
    if new_fold
      call s:place_sign(s:end_sign_id(), buffer, a:end_line, 'HlFoldEnd')
    endif
  endif

  " remove old mid signs
  if len(b:hl_fold_line) > 2
    for line in b:hl_fold_lines[1:-2]
      if line < a:start_line || line > a:end_line
        call s:unplace_sign(s:mid_sign_id(line), buffer)
      endif
    endfor
  endif

  " add new mid signs
  if a:end_line > a:start_line + 1
    let lines = [a:start_line]
    let line = a:start_line + 1
    while line < a:end_line
      call add(lines, line)
      if index(new_line, b:hl_fold_lines) != -1
        call s:place_sign(s:mid_sign_id(line), buffer, line, 'HlFoldMid')
      endif
    endwhile
    call add(lines, a:end_line)
  endif

  let b:hl_fold_lines = lines
endfunction

function! s:place_sign(sign_id, buffer, line, name)
  " wrapper for placing a sign
  execute 'sign place ' . a:sign_id
        \ . ' line=' . a:line
        \ . ' name=' . a:name
        \ . ' buffer=' . a:buffer
endfunction

function! s:unplace_sign(sign_id, buffer)
  " wrapper for unplacing a sign
  execute 'sign unplace ' . a:sign_id
        \ . ' buffer=' . a:buffer
endfunction

function! s:start_sign_id()
  return g:hl_fold_sign_id_offset
endfunction

function! s:end_sign_id()
  return g:hl_fold_sign_id_offset + 1
endfunction

function! s:mid_sign_id(line)
  return g:hl_fold_sign_id_offset + a:line + 2
endfunction
