if exists('g:hl_fold_loaded')
  finish
endif
let g:hl_fold_loaded = 1

if !exists('g:hl_fold_enabled')
  let g:hl_fold_enabled = 1
end
if !exists('g:hl_fold_min_level')
  let g:hl_fold_min_level = 0
end
if !exists('g:hl_fold_max_size')
  let g:hl_fold_max_size = 40
end
if !exists('g:hl_fold_filetypes')
  let g:hl_fold_filetypes = '*'
end
if !exists('g:hl_fold_cursor_hold')
  let g:hl_fold_cursor_hold = 0.1
end
if !exists('g:hl_fold_sign_id_offset')
  let g:hl_fold_sign_id_offset = 1000
end

if !exists('g:hl_fold_start_linehl')
  let g:hl_fold_start_linehl = ''
end
if !exists('g:hl_fold_mid_linehl')
  let g:hl_fold_mid_linehl = ''
end
if !exists('g:hl_fold_end_linehl')
  let g:hl_fold_end_linehl = ''
end

if !exists('g:hl_fold_start_text')
  let g:hl_fold_start_text = '┌'
end
if !exists('g:hl_fold_mid_text')
  let g:hl_fold_mid_text = '│'
end
if !exists('g:hl_fold_end_text')
  let g:hl_fold_end_text = '└'
end

if !exists('g:hl_fold_start_texthl')
  let g:hl_fold_start_texthl = 'LineNr'
end
if !exists('g:hl_fold_mid_texthl')
  let g:hl_fold_mid_texthl = 'LineNr'
end
if !exists('g:hl_fold_end_texthl')
  let g:hl_fold_end_texthl = 'LineNr'
end

function! hl_fold#define_sign(name, linehl, text, texthl)
  let definition = 'sign define ' . a:name
  if !empty(a:linehl)
    let definition .= ' linehl=' . a:linehl
  endif
  if !empty(a:text)
    let definition .= ' text=' . a:text
  endif
  if !empty(a:texthl)
    let definition .= ' texthl=' . a:texthl
  endif
  execute definition
endfunction

call hl_fold#define_sign('HlFoldStart',
      \ g:hl_fold_start_linehl,
      \ g:hl_fold_start_text,
      \ g:hl_fold_start_texthl)
call hl_fold#define_sign('HlFoldMid',
      \ g:hl_fold_mid_linehl,
      \ g:hl_fold_mid_text,
      \ g:hl_fold_mid_texthl)
call hl_fold#define_sign('HlFoldEnd',
      \ g:hl_fold_end_linehl,
      \ g:hl_fold_end_text,
      \ g:hl_fold_end_texthl)

command! HlFoldToggle call hl_fold#toggle()
command! HlFoldEnable call hl_fold#enable()
command! HlFoldDisable call hl_fold#disable()
command! HlFoldShow call hl_fold#show()
command! HlFoldHide call hl_fold#hide()

if g:hl_fold_enabled
  HlFoldEnable
endif
