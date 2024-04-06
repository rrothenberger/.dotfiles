#!/usr/bin/env bash

if [ -z "$HOME" ]; then
  echo '$HOME not set'
  exit 1
fi

set -eo pipefail

user_home=$HOME

set -u

temp=$(mktemp -d)
sudo mkdir -p /opt
curl -Lo "${temp}/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar -xzf "${temp}/nvim.tar.gz" -C "${temp}"
if [ -d "/opt/nvim" ]; then
  echo "Removing old nvim installation..."
  sudo rm -rf /opt/nvim
fi

if [ -L "/usr/local/bin/nvim" ] || [ -f "/usr/local/bin/nvim" ]; then
  sudo rm -rf /usr/local/bin/nvim
fi

sudo mv "${temp}/nvim-linux64" "/opt/nvim"
sudo ln -s "/opt/nvim/bin/nvim" "/usr/local/bin/nvim"

sudo apt-add-repository -y ppa:git-core/ppa
sudo apt update -y
sudo apt install -y zsh git tmux gnupg2 fzf htop build-essential autoconf \
                    m4 libncurses5-dev libwxgtk3.0-gtk3-dev  libwxgtk-webview3.0-gtk3-dev \
	                  libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2 \
										libxml2-utils libreadline-dev libyaml-dev \
										scdaemon yubikey-personalization yubikey-manager kitty direnv
chsh -s $(which zsh)

