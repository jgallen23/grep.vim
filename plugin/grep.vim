function! Grep_exec(cmd, pattern)
  let cmd_output = system(a:cmd)
  if cmd_output == ""
    echomsg "Pattern " . a:pattern . " not found"
    return
  endif

  let tmpfile = tempname()
  exe "redir! > " . tmpfile
  silent echon '[grep search for "'.a:pattern.'"]'."\n"
  silent echon cmd_output
  redir END

  let old_efm = &efm
  set efm=%f:%\\s%#%l:%m

  execute "silent! cgetfile " . tmpfile
  let &efm = old_efm
  botright copen

  call delete(tmpfile)

endfunction

function! Grep(pattern)

  let exclude_dir = '--exclude-dir ' . join(g:grep_excludes_dir, ' --exclude-dir ')
  let pattern = a:pattern

  let cmd = 'grep -rsinI '.exclude_dir.' "'.pattern.'" *'

  call Grep_exec(cmd, pattern)

endfunction

function! s:GetSelection()
  try
    let a_save = @a
    normal! gv"ay
    return @a
  finally
    let @a = a_save
  endtry
endfunction

function! s:GrepSelection()
  let sel = s:GetSelection()
  call Grep(sel)
endfunction

if !exists('g:grep_excludes_dir')
  let g:grep_excludes_dir = ['.git', '.svn']
endif

command! -nargs=1 Grep call Grep(<f-args>)
command! -range GrepSelection call s:GrepSelection()
