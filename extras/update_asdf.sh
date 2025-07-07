#!/usr/bin/env bash

set -eo pipefail
set -u

if [[ "$(uname -s)" == "Darwin" ]]; then
  brew install asdf
  exit 0
fi

temp=$(mktemp -d)
trap "rm -r $temp" EXIT

sudo mkdir -p /opt
curl -Lo "${temp}/asdf.tar.gz" "https://github.com/asdf-vm/asdf/releases/latest/download/asdf-$(curl https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name')-linux-amd64.tar.gz"
tar -xzf "${temp}/asdf.tar.gz" -C "${temp}"

if [ -f "/opt/asdf" ]; then
  echo "Removing old asdf installation..."
  sudo rm /opt/asdf
fi

if [ -L "/usr/local/bin/asdf" ] || [ -f "/usr/local/bin/asdf" ]; then
  sudo rm -rf /usr/local/bin/asdf
fi
sudo mv "${temp}/asdf" "/opt/asdf"
sudo ln -s "/opt/asdf" "/usr/local/bin/asdf"

