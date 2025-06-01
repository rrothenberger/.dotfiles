#!/usr/bin/env bash

set -eo pipefail
set -u

temp=$(mktemp -d)
sudo mkdir -p /opt
curl -Lo "${temp}/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -xzf "${temp}/nvim.tar.gz" -C "${temp}"
if [ -d "/opt/nvim" ]; then
  echo "Removing old nvim installation..."
  sudo rm -rf /opt/nvim
fi

if [ -L "/usr/local/bin/nvim" ] || [ -f "/usr/local/bin/nvim" ]; then
  sudo rm -rf /usr/local/bin/nvim
fi

sudo mv "${temp}/nvim-linux-x86_64" "/opt/nvim"
sudo ln -s "/opt/nvim/bin/nvim" "/usr/local/bin/nvim"
