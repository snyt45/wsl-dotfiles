if has('nvim')
  let s:rc_dir = expand('~/.config/nvim/rc')
endif

" rcファイル読み込み関数
function! s:source_rc(rc_file_name)
  let rc_file = expand(s:rc_dir . '/' . a:rc_file_name)
  if filereadable(rc_file)
      execute 'source' rc_file
  endif
endfunction

" 基本設定
call s:source_rc('init.rc.vim')

" クリップボード
call s:source_rc('clipboard.rc.vim')

" pyenv
call s:source_rc('pyenv.rc.vim')

" dein
call s:source_rc('dein.rc.vim')

