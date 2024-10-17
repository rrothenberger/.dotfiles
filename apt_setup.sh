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

sudo apt-add-repository -y ppa:git-core/ppa
sudo apt update -y
sudo apt install -y zsh git tmux gnupg2 fzf htop build-essential autoconf inotify-tools \
                    m4 libncurses5-dev libwxgtk3.0-gtk3-dev  libwxgtk-webview3.0-gtk3-dev \
                    libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2 \
                    libxml2-utils libreadline-dev libyaml-dev uuid-dev pkg-config \
                    libssl-dev zlib1g-dev libcurl4-openssl-dev icu-devtools libicu-dev \
                    scdaemon yubikey-personalization yubikey-manager kitty oathtool jq

sudo snap install yq
chsh -s $(which zsh)

./extras/update_direnv.sh
./extras/update_cosign.sh

./extras/update_minio.sh
./extras/update_mc.sh

if [[ ! -f "/usr/lib/systemd/user/minio.service" ]] && [[ ! -L "/usr/lib/systemd/user/minio.service" ]]; then
  echo "Linking minio.service..."
  sudo ln -s "${script_path}/minio/minio.service" /usr/lib/systemd/user/minio.service
  systemctl --user daemon-reload
fi
grep -qE "^127.0.0.1\s+minio.local\$" /etc/hosts || sudo sh -c 'echo "127.0.0.1       minio.local" >> /etc/hosts'

if [ ! -z "$install_docker" ]; then
  temp=$(mktemp -d)
  sudo apt install gnome-terminal

  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  curl -Lo "${temp}/docker.deb" "https://desktop.docker.com/linux/main/amd64/145265/docker-desktop-4.29.0-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"
  sudo apt install -y "${temp}/docker.deb"
fi

