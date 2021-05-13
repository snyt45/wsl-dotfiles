#!/bin/sh

readonly DOTPATH=~/.dotfiles

# Color Palette Constant
readonly GRAY="\033[1;38;5;243m"
readonly BLUE="\033[1;34m"
readonly GREEN="\033[1;32m"
readonly RED="\033[1;31m"
readonly PURPLE="\033[1;35m"
readonly YELLOW="\033[1;33m"
readonly NONE="\033[0m"

title() {
    echo "${PURPLE}$1${NONE}"
    echo "${GRAY}==============================${NONE}"
}

error() {
    echo -e "${RED}Error: ${NONE}$1"
    exit 1
}

warning() {
    echo -e "$YELLOW}Warning: ${NONE}$1"
}

info() {
    echo "${BLUE}Info: ${NONE}$1"
}

success() {
    echo "${GREEN}$1${NONE}"
}

check_shell() {
    readlink /proc/$$/exe
}

setup_symlinks() {
    info "Setup dotfiles"

    # ~/
    home_target=${DOTPATH}/.??*
    home_target=$(eval echo $home_target) # ワイルドカードを展開するために必要
    for f in $home_target;
    do
        [ `basename $f` = ".gitignore" ] && continue
        [ `basename $f` = ".git" ] && continue

        ln -snfv "$f" ~/
    done

    # ~/bin
    mkdir -p "$HOME/bin"
    bin_target=${DOTPATH}/bin/*.exe
    bin_target=$(eval echo $bin_target)
    for f in $bin_target;
    do
        ln -snfv "$f" ~/bin/
    done

    # ~/.config
    mkdir -p "$HOME/.config"
    
    # ~/.config/fish
    mkdir -p "$HOME/.config/fish"
    fish_target="${DOTPATH}/config/fish/*.fish \
                 ${DOTPATH}/config/fish_variables"
    fish_target=$(eval echo $fish_target)
    for f in $fish_target;
    do
        ln -snfv "$f" ~/.config/fish/
    done

    # ~/.config/fish/conf.d
    mkdir -p "$HOME/.config/fish/conf.d"
    confd_target=${DOTPATH}/config/fish/conf.d/*.fish
    confd_target=$(eval echo $confd_target)
    for f in $confd_target;
    do
        ln -snfv "$f" ~/.config/fish/conf.d/
    done

    # ~/.config/nvim
    mkdir -p "$HOME/.config/nvim"
    nvim_target=${DOTPATH}/config/nvim/*.vim
    nvim_target=$(eval echo $nvim_target)
    for f in $nvim_target;
    do
        ln -snfv "$f" ~/.config/nvim/
    done

    # ~/.config/nvim/dein
    mkdir -p "$HOME/.config/nvim/dein"
    dein_target=${DOTPATH}/config/nvim/dein/*.toml
    dein_target=$(eval echo $dein_target)
    for f in $dein_target;
    do
        ln -snfv "$f" ~/.config/nvim/dein/
    done

    # ~/.config/nvim/rc
    mkdir -p "$HOME/.config/nvim/rc"
    rc_target=${DOTPATH}/config/nvim/rc/*.vim
    rc_target=$(eval echo $rc_target)
    for f in $rc_target;
    do
        ln -snfv "$f" ~/.config/nvim/rc/
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
        test -r ~/.profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> ~/.profile
        test -r ~/.bash_profile && . ~/.bash_profile
        test -r ~/.profile && . ~/.profile
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
        exec $SHELL -l
        info "Restart the shell with the login shell >> $SHELL"
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
    #. ~/.pyenv/versions/2.7.17/envs/py2/bin/activate
    pyenv activate py2
    pip install neovim

    #. ~/.pyenv/versions/3.9.1/envs/py3/bin/activate
    pyenv activate py3
    pip install neovim

    # ruby
    rbenv install 2.7.2
    rbenv global 2.7.2

    # gemコマンドを使えるようにする
    echo 'eval "$(rbenv init -)"' >> ~/.profile
    . ~/.profile
    gem install neovim

    # Node.js
    npm install -g neovim
}

case "$1" in
    check_shell)
        check_shell
        ;;
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
