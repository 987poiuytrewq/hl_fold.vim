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
  let g:hl_fold_enabled = 1
  augroup hl_fold
    autocmd CursorMoved <buffer> call hl_fold#show_lazy()
    autocmd CursorHold <buffer> call hl_fold#show()
  augroup END
  call hl_fold#show()
endfunction

function! hl_fold#disable()
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

  " only update signs if the fold has changed

  let old_fold = exists('b:hl_fold_start_line') && exists('b:hl_fold_end_line')
  let new_fold = a:end_line > a:start_line
  let update_start = !old_fold || !new_fold || a:start_line != b:hl_fold_start_line
  let update_end = !old_fold || !new_fold || a:end_line != b:hl_fold_end_line

  if update_start
    " move the start sign
    call s:unplace_sign(s:start_sign_id(), buffer)
    if new_fold
      call s:place_sign(s:start_sign_id(), buffer, a:start_line, 'HlFoldStart')
    endif
  endif

  if update_end
    " move the end sign
    call s:unplace_sign(s:end_sign_id(), buffer)
    if new_fold
      call s:place_sign(s:end_sign_id(), buffer, a:end_line, 'HlFoldEnd')
    endif
  endif

  if update_start || update_end
    if exists('b:hl_fold_start_line') && exists('b:hl_fold_end_line')
      " unplace signs inside old fold but not inside new fold and
      " place signs inside new fold but not inside old fold
      let line = min([a:start_line, b:hl_fold_start_line])
      while line < max([a:end_line, b:hl_fold_end_line])
        if line > b:hl_fold_start_line && line < b:hl_fold_end_line
              \ && (line <= a:start_line || line >= a:end_line)
          " line in old fold but not in new fold
          call s:unplace_sign(s:mid_sign_id(line), buffer)
        elseif new_fold
              \ && line > a:start_line && line < a:end_line
              \ && (line <= b:hl_fold_start_line || line >= b:hl_fold_end_line)
          " line in new fold but not in old fold
          call s:place_sign(s:mid_sign_id(line), buffer, line, 'HlFoldMid')
        endif
        let line += 1
      endwhile
    else
      " just place the mid signs
      let line = a:start_line + 1
      while line < a:end_line
        call s:place_sign(s:mid_sign_id(line), buffer, line, 'HlFoldMid')
        let line += 1
      endwhile
    endif
  endif

  if new_fold
    let b:hl_fold_start_line = a:start_line
    let b:hl_fold_end_line = a:end_line
  elseif old_fold
    unlet b:hl_fold_start_line
    unlet b:hl_fold_end_line
  endif
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

if g:hl_fold_enabled
  call hl_fold#enable()
endif
