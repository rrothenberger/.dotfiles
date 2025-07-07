#!/usr/bin/env bash

if [ -z "$HOME" ]; then
  echo '$HOME not set'
  exit 1
fi

set -eo pipefail

user_home=$HOME

set -u

sudo mkdir -p /usr/local/opt
sudo mkdir -p /usr/local/bin

./extras/update_nvim.sh

echo -n "" > $user_home/.zprofile
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $user_home/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

homebrew=$(brew --prefix)

brew install tmux gpg2 fzf pinentry-mac jq coreutils direnv ripgrep autoconf openssl \
             wxwidgets fop libxslt icu4c pkg-config libyaml libpq

if [ -L "/usr/local/bin/gpg2" ] || [ -f "/usr/local/bin/gpg2" ]; then
  sudo rm /usr/local/bin/gpg2
fi
sudo ln -s $(brew --prefix gpg)/bin/gpg /usr/local/bin/gpg2

echo "pinentry-program $(brew --prefix pinentry-mac)/bin/pinentry-mac" >> ${homebrew}/etc/gnupg/gpg-agent.conf
echo "export LDFLAGS=\"-L$(brew --prefix icu4c)/lib\"" > $user_home/.zshenv
echo "export CPPFLAGS=\"-I$(brew --prefix icu4c)/include\"" >> $user_home/.zshenv
echo "export PKG_CONFIG_PATH=\"$(brew --prefix icu4c)/lib/pkgconfig:\$PKG_CONFIG_PATH\"" >> $user_home/.zshenv

brew install --cask wezterm

./extras/update_asdf.sh

echo "Remember to source ~/.zshenv"
