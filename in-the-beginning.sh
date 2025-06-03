#!/bin/bash -e

# vimrc
if [ ! -L ~/.vimrc ]; then
ln -s $(pwd)/.vimrc ~/.vimrc
fi

# update vim
brew install vim
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
vim --version | grep "VIM"

# homebrew
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ "$(uname -m)" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  brew -v
else
  echo "Homebrewは既にインストールされています。$(brew -v)"
fi

# nvm
if ! command -v nvm &>/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  nvm -v
else
  echo "nvm aru $(nvm -v)"
fi

# deno
brew install deno
