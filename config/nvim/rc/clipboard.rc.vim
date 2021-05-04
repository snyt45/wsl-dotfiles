" NeovimでヤンクしたテキストをWindowsに貼り付けできるようにする
set clipboard=unnamedplus
let g:clipboard = {
  \   'name': 'myClipboard',
  \   'copy': {
  \      '+': 'win32yank.exe -i',
  \      '*': 'win32yank.exe -i',
  \    },
  \   'paste': {
  \      '+': 'win32yank.exe -o',
  \      '*': 'win32yank.exe -o',
  \   },
  \   'cache_enabled': 1,
  \ }
