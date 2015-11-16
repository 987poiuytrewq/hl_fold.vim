let g:hl_fold_sign_id_offset = 1000
sign define HlFoldStart text=┌
sign define HlFoldMid   text=│
sign define HlFoldEnd   text=└

autocmd CursorMoved <buffer> call hl_fold#highlight_fold()

function! hl_fold#highlight_fold()
  " find fold level edges and highlight them
  let initial_line = line('.')
  let start_line = s:find_fold_edge(initial_line, -1)
  let end_line = s:find_fold_edge(initial_line, +1)

  call s:update_signs(start_line, end_line)

  let b:hl_fold_start_line = start_line
  let b:hl_fold_end_line = end_line
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
  " update the current signs to the new signs, updating the minimum
  " number of signs in the process
  let buffer = bufnr('%')

  " due to the nature of folds, we need only see if the start has moved to
  " infer that the end has also moved
  if (exists('b:hl_fold_start_line') && a:start_line != b:hl_fold_start_line) || !exists('b:hl_fold_start_line')
    " unplace signs
    call s:unplace_sign(s:start_sign_id(), buffer)
    call s:unplace_sign(s:end_sign_id(), buffer)
    if a:end_line > a:start_line
      " place new signs
      call s:place_sign(s:start_sign_id(), buffer, a:start_line, 'HlFoldStart')
      call s:place_sign(s:end_sign_id(), buffer, a:end_line, 'HlFoldEnd')
    endif
  end

  " diff the mid ranges and unplace those outside the fold and place those
  " newly inside the fold, leaving others unchanged
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
  execute 'sign unplace ' .a:sign_id
        \ . ' buffer=' . a:buffer
endfunction

function! s:start_sign_id()
  return g:hl_fold_sign_id_offset - 1
endfunction

function! s:end_sign_id()
  return g:hl_fold_sign_id_offset - 2
endfunction

function! s:mid_sign_id(line)
  return g:hl_fold_sign_id_offset + line
endfunction
