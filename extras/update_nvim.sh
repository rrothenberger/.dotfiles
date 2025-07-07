#!/usr/bin/env bash

set -eo pipefail
set -u

platform="linux-x86_64"
if [[ "$(uname -s)" == "Darwin" ]];  then
  platform="macos-x86_64"
  if [[ "$(uname -p)" == "arm" ]]; then
    platform="macos-arm64"
  fi
fi

temp=$(mktemp -d)
trap "rm -r $temp" EXIT

sudo mkdir -p /opt
curl -Lo "${temp}/nvim.tar.gz" "https://github.com/neovim/neovim/releases/latest/download/nvim-${platform}.tar.gz"
tar -xzf "${temp}/nvim.tar.gz" -C "${temp}"
if [ -d "/opt/nvim" ]; then
  echo "Removing old nvim installation..."
  sudo rm -rf /opt/nvim
fi

if [ -L "/usr/local/bin/nvim" ] || [ -f "/usr/local/bin/nvim" ]; then
  sudo rm -rf /usr/local/bin/nvim
fi

sudo mv "${temp}/nvim-${platform}" "/opt/nvim"
sudo ln -s "/opt/nvim/bin/nvim" "/usr/local/bin/nvim"
