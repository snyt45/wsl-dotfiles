#!/bin/bash

DOTFILES="$(pwd)"
COLOR_GRAY="\033[1;38;5;243m"
COLOR_BLUE="\033[1;34m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_PURPLE="\033[1;35m"
COLOR_YELLOW="\033[1;33m"
COLOR_NONE="\033[0m"

title() {
    echo "${COLOR_PURPLE}$1${COLOR_NONE}"
    echo "${COLOR_GRAY}==============================${COLOR_NONE}"
}

error() {
    echo -e "${COLOR_RED}Error: ${COLOR_NONE}$1"
    exit 1
}

warning() {
    echo -e "${COLOR_YELLOW}Warning: ${COLOR_NONE}$1"
}

info() {
    echo "${COLOR_BLUE}Info: ${COLOR_NONE}$1"
}

success() {
    echo "${COLOR_GREEN}$1${COLOR_NONE}"
}

setup_symlinks() {
    title "Setting up symlinks"

    # ~
    for f in .??*; do
      [ "$f" = ".gitignore" ] && continue

      ln -snfv "$DOTFILES/$f" ~/
    done
    ln -snfv "$DOTFILES/Brewfile" ~/

    # bin
    mkdir -p "$HOME/bin"
    for f in bin/.??*; do
      ln -snfv "$DOTFILES/bin/$f" ~/bin/
    done
    
    # config
    mkdir -p "$HOME/config"

    mkdir -p "$HOME/config/fish"
    for f in config/fish/.??*; do
      ln -snfv "$DOTFILES/config/fish/$f" ~/config/fish/
    done
    mkdir -p "$HOME/config/fish/conf.d"
    for f in config/fish/conf.d/.??*; do
      ln -snfv "$DOTFILES/config/fish/conf.d/$f" ~/config/fish/conf.d/
    done

    mkdir -p "$HOME/config/nvim"
    for f in config/nvim/.??*; do
      ln -snfv "$DOTFILES/config/nvim/$f" ~/config/nvim/
    done
    mkdir -p "$HOME/config/nvim/dein"
    for f in config/nvim/dein/.??*; do
      ln -snfv "$DOTFILES/config/nvim/dein/$f" ~/config/nvim/dein/
    done
    mkdir -p "$HOME/config/nvim/rc"
    for f in config/nvim/rc/.??*; do
      ln -snfv "$DOTFILES/config/nvim/rc/$f" ~/config/nvim/rc/
    done

}

setup_homebrew() {
    title "homebrew install & brew bundle"

    # Setup prerequisites
    sudo apt update
    sudo apt install build-essential

    if test ! "$(command -v brew)"; then
        info "Homebrew not installed. Installing."
        # Run as a login shell (non-interactive) so that the script doesn't pause for user input
        curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash --login
    fi

    if [ "$(uname)" = "Linux" ]; then
        test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
        test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.bash_profile
        echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.profile
    fi

    # install brew dependencies from Brewfile
    brew update
    brew bundle
}

setup_shell() {
    title "Configuring shell"

    [ -n "$(command -v brew)" ] && fish_path="$(brew --prefix)/bin/fish" || fish_path="$(which fish)"
    if ! grep "$fish_path" /etc/shells; then
        info "adding $fish_path to /etc/shells"
        echo "$fish_path" | sudo tee -a /etc/shells
    fi

    if [ "$SHELL" != "$fish_path" ]; then
        chsh -s "$fish_path"
        info "default shell changed to $fish_path"
    fi
}

setup_git() {
    title "Setting up Git"

    defaultName=$(git config user.name)
    defaultEmail=$(git config user.email)

    read -rp "Name [$defaultName] " name
    read -rp "Email [$defaultEmail] " email

    git config --global user.name "${name:-$defaultName}"
    git config --global user.email "${email:-$defaultEmail}"

    read -rp "Save user and password to an unencrypted file to avoid writing? [y/N] " save
    if [ $save = y ]; then
        git config --global credential.helper "store"
    else
        git config --global credential.helper "cache --timeout 3600"
    fi
}

setup_neovim() {
    title "Setting up Neovim"

    # dein install
    curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
    sh ./installer.sh ~/.cache/dein
    rm -rf installer.sh

    # clipboard
    sudo chmod +x ~/bin/win32yank.exe

    # pyenv setup
    # https://github.com/pyenv/pyenv/wiki/Common-build-problems
    sudo apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git

    pyenv install 2.7.17
    pyenv install 3.9.1

    pyenv virtualenv 2.7.17 py2
    pyenv virtualenv 3.9.1 py3

    # issue: https://github.com/pyenv/pyenv-virtualenv/issues/284
    . ~/.pyenv/versions/2.7.17/envs/py2/bin/activate.fish
    # pyenv activate py2
    pip install neovim

    . ~/.pyenv/versions/3.9.1/envs/py3/bin/activate.fish
    # pyenv activate py3
    pip install neovim

    # ruby
    rbenv install 2.7.2
    rbenv global 2.7.2

    # gemコマンドを使えるようにする
    echo 'eval "$(rbenv init -)"' >> ~/.profile
    gem install neovim

    # Node.js
    npm install -g neovim
}

case "$1" in
    link)
        setup_symlinks
        ;;
    git)
        setup_git
        ;;
    homebrew)
        setup_homebrew
        ;;
    shell)
        setup_shell
        ;;
    neovim)
        setup_neovim
        ;;
    all)
        setup_symlinks
        setup_homebrew
        setup_shell
        setup_git
        setup_neovim
        ;;
    *)
        echo -e $"\nUsage: $(basename "$0") {link|git|homebrew|shell|neovim|all}\n"
        exit 1
        ;;
esac

success "Done."




























































#-------------------------------------------------------------------------------
# neovim setup
#-------------------------------------------------------------------------------
