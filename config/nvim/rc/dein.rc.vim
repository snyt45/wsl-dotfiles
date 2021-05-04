" https://github.com/Shougo/dein.vim
if &compatible
  set nocompatible
endif

" Pluginディレクトリのパス
let s:dein_dir = expand('~/.cache/dein')
" dein.vimのパス
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" tomlのディレクトリへのパス
let s:toml_dir = expand('~/.config/nvim/dein')

" Required:
execute 'set runtimepath+=' . s:dein_repo_dir

" Required:
call dein#begin(s:dein_dir)

" 起動時に読み込むプラグイン群のtoml
call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})

" ファイルタイプに応じて都度読み込むプラグインのtoml
call dein#load_toml(s:toml_dir . '/lazy.toml', {'lazy': 1})

" Required:
call dein#end()

" Required:
filetype plugin indent on
syntax enable

" 不足プラグインの自動インストール
if dein#check_install()
 call dein#install()
endif

