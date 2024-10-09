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
                    gnupg2 kitty oathtool jq libuuid-devel

chsh -s $(which zsh)

./extras/update_direnv.sh
./extras/update_cosign.sh
