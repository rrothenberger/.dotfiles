#!/usr/bin/env bash

if [ -z "$HOME" ]; then
  echo '$HOME not set'
  exit 1
fi

set -eo pipefail

user_home=$HOME
install_docker=$INSTALL_DOCKER
set -u

./extras/update_nvim.sh

sudo dnf install -y zsh fzf git-all yq make automake gcc gcc-c++ kernel-devel autoconf inotify-tools readline-devel \
                    ncurses-devel ncurses-libs wxGTK-devel wxBase openssl-devel libiodbc unixODBC-devel.x86_64 \
                    erlang-odbc.x86_64 libxslt fop libyaml-devel uuid-devel pkgconfig libcurl-devel icu libicu-devel \
                    gnupg2 kitty oathtool jq libuuid-devel gnupg-pkcs11-scd pcsc-lite-ccid pcsc-tools yubikey-manager

sudo dnf remove opensc
sudo systemctl enable pcscd
sudo systemctl start pcscd

chsh -s $(which zsh)

./extras/update_direnv.sh
./extras/update_cosign.sh

if [ ! -z "$install_docker" ]; then
  temp=$(mktemp -d)
  sudo dnf install -y gnome-terminal dnf-plugins-core
  echo "Install this extensions: https://extensions.gnome.org/extension/615/appindicator-support/"
  echo "Press enter to continue"
  read
  sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  curl -Lo "${temp}/docker.rpm" https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm
  sudo dnf install "${temp}/docker.rpm"
fi
