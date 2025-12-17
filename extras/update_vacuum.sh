#!/usr/bin/env bash

set -eo pipefail
set -u

platform="linux_x86_64"
if [[ "$(uname -s)" == "Darwin" ]];  then
  platform="macos_x86_64"
  if [[ "$(uname -p)" == "arm" ]]; then
    platform="macos_arm64"
  fi
fi

temp=$(mktemp -d)
trap "rm -r $temp" EXIT

sudo mkdir -p /opt

tag=$(curl https://api.github.com/repos/daveshanley/vacuum/releases/latest | jq -r '.tag_name' | cut -d"v" -f 2)
curl -Lo "${temp}/vacuum.tar.gz" "https://github.com/daveshanley/vacuum/releases/download/v${tag}/vacuum_${tag}_${platform}.tar.gz"
tar -xzf "${temp}/vacuum.tar.gz" -C "${temp}"

if [ -f "/opt/vacuum" ]; then
  echo "Removing old vacuum installation..."
  sudo rm -rf /opt/vacuum
fi

if [ -L "/usr/local/bin/vacuum" ] || [ -f "/usr/local/bin/vacuum" ]; then
  sudo rm -rf /usr/local/bin/vacuum
fi

sudo mv "${temp}/vacuum" "/opt/vacuum"
sudo ln -s "/opt/vacuum" "/usr/local/bin/vacuum"
