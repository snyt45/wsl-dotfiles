# Setup
```
git clone https://github.com/snyt45/wsl-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
sh install.sh all
# シェル再起動して実行
cd ~/.dotfiles
sh install.sh neovim
```

# WSL パーミッション問題
git cloneなどコマンド経由の場合、ディレクトリ/ファイルのパーミッションがroot権限になる。

とりあえず、下記で解決できている。

`/etc/wsl.conf`を作成

```/etc/wsl.conf
options = "metadata,umask=22,fmask=11,uid=1000,gid=1000"
```
