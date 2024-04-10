#!/usr/bin/env bash

if [ -z "$HOME" ]; then
  echo '$HOME not set'
  exit 1
fi

set -eo pipefail

user_home=$HOME
install_docker=$INSTALL_DOCKER
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
										libxml2-utils libreadline-dev libyaml-dev uuid-dev pkg-config \
										libssl-dev zlib1g-dev libcurl4-openssl-dev icu-devtools libicu-dev \
										scdaemon yubikey-personalization yubikey-manager kitty oathtool jq

sudo snap install yq
chsh -s $(which zsh)

if [ -f "/opt/direnv" ]; then
	echo "Removing old direnv installation..."
	sudo rm /opt/direnv 
fi
sudo curl -Lo "/opt/direnv" https://github.com/direnv/direnv/releases/latest/download/direnv.linux-amd64
sudo chmod +x /opt/direnv
if [ -L "/usr/local/bin/direnv" ] || [ -f "/usr/local/bin/direnv" ]; then
  sudo rm -rf /usr/local/bin/direnv
fi
sudo ln -s /opt/direnv /usr/local/bin/direnv

if [ ! -z "$install_docker" ]; then
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

