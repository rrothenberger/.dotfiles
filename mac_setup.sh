#!/usr/bin/env bash

if [ -z "$HOME" ]; then
  echo '$HOME not set'
  exit 1
fi

set -eo pipefail

user_home=$HOME

set -u

temp=$(mktemp -d)
sudo mkdir -p /usr/local/opt
sudo mkdir -p /usr/local/bin
curl -Lo "${temp}/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-macos.tar.gz
tar -xzf "${temp}/nvim.tar.gz" -C "${temp}"
if [ -d "/usr/local/opt/nvim" ]; then
  echo "Removing old nvim installation..."
  sudo rm -rf /usr/local/opt/nvim
fi

if [ -L "/usr/local/bin/nvim" ] || [ -f "/usr/local/bin/nvim" ]; then
  sudo rm -rf /usr/local/bin/nvim
fi

sudo mv "${temp}/nvim-macos" "/usr/local/opt/nvim"
sudo ln -s "/usr/local/opt/nvim/bin/nvim" "/usr/local/bin/nvim"

echo -n "" > $user_home/.zprofile
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $user_home/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install tmux gpg2 fzf pinentry-mac kitty jq coreutils direnv ripgrep \
             autoconf openssl wxwidgets fop libxslt \
             icu4c pkg-config libyaml

if [ -L "/usr/local/bin/gpg2" ] || [ -f "/usr/local/bin/gpg2" ]; then
  sudo rm /usr/local/bin/gpg2
fi
sudo ln -s $(brew --prefix gpg)/bin/gpg /usr/local/bin/gpg2
echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> /opt/homebrew/etc/gnupg/gpg-agent.conf

echo 'export LDFLAGS="-L/opt/homebrew/opt/icu4c/lib"' > $user_home/.zshenv
echo 'export CPPFLAGS="-I/opt/homebrew/opt/icu4c/include"' >> $user_home/.zshenv
echo 'export PKG_CONFIG_PATH="/opt/homebrew/Cellar/icu4c/74.2/lib/pkgconfig:$PKG_CONFIG_PATH"' >> $user_home/.zshenv

echo "Remember to source ~/.zshenv"
