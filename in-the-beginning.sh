#!/bin/bash -e

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# カレントディレクトのまま分割
# iteam -> settings -> Profiles -> General -> Initial directory -> Advanced Configuration -> Working Directory for New Split Panes -> Resume previous session's directory`

# homebrew系のインストール
brew tap dart-lang/dart
brew trust dart-lang/dart

brew install \
	git \
	stylua \
	gh \
	jq \
	fzf \
	ripgrep \
	herdr \
  neovim \
	dart \
	mise \


# neovim
mkdir -p ~/.config/nvim
if [ ! -L ~/.config/nvim/init.lua ]; then
  ln -s "$SCRIPT_DIR/init.lua" ~/.config/nvim/init.lua
fi
nvim --version | grep "NVIM"
# :Lazy
# :Mason
# :checkhealth

# ghostty
brew install --cask ghostty
brew install --cask font-moralerspace
mkdir -p ~/.config/ghostty
if [ ! -L ~/.config/ghostty/config.ghostty ]; then
  ln -s "$SCRIPT_DIR/ghostty/config.ghostty" ~/.config/ghostty/config.ghostty
fi

# cmux
# brew tap manaflow-ai/cmux
# brew install --cask cmux

# nvm
if ! command -v nvm &>/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  nvm -v
else
  echo "nvm aru $(nvm -v)"
fi

# node
nvm install --lts
nvm alias default 'lts/*'
nvm use default

# bun
curl -fsSL https://bun.sh/install | bash

# elm
# https://guide.elm-lang.org/install/elm.html

# claude code
curl -fsSL https://claude.ai/install.sh | bash
# claude desktop
# https://claude.com/ja/download

# codex
curl -fsSL https://chatgpt.com/codex/install.sh | sh
