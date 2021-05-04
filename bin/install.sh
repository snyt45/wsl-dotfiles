#-------------------------------------------------------------------------------
# symlink
#-------------------------------------------------------------------------------
# bin => ~/bin
# config => ~/.config
# .inputrc => ~/.inputrc
# Brewfile => ~/Brewfile

#-------------------------------------------------------------------------------
# homebrew install & brew bundle
#-------------------------------------------------------------------------------
sudo apt update
sudo apt install build-essential

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login

test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

# ここで必要なパッケージを全てインストールする
brew update
brew bundle

#-------------------------------------------------------------------------------
# fish setup
#-------------------------------------------------------------------------------
sudo -e /etc/shells
echo "/home/linuxbrew/.linuxbrew/bin/fish" | sudo tee -a /etc/shells
chsh -s /home/linuxbrew/.linuxbrew/bin/fish

#-------------------------------------------------------------------------------
# neovim setup
#-------------------------------------------------------------------------------

# dein install
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh \> installer.sh
sh ./installer.sh ~/.cache/dein
rm -rf installer.sh

# pyenv setup
# https://github.com/pyenv/pyenv/wiki/Common-build-problems
sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

pyenv install 2.7.17
pyenv install 3.9.1

pyenv virtualenv 2.7.17 py2
pyenv virtualenv 3.9.1 py3

pyenv activate py2
pip install neovim

pyenv activate py3
pip install neovim

# ruby
rbenv install 2.7.2
rbenv global 2.7.2

gem install neovim

# Node.js
npm install -g neovim
