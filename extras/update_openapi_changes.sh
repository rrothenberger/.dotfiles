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

tag=$(curl https://api.github.com/repos/pb33f/openapi-changes/releases/latest | jq -r '.tag_name' | cut -d"v" -f 2)
curl -Lo "${temp}/openapi-changes.tar.gz" "https://github.com/pb33f/openapi-changes/releases/download/v${tag}/openapi-changes_${tag}_${platform}.tar.gz"
echo "https://github.com/pb33f/openapi-changes/releases/download/v${tag}/openapi-changes_${tag}_${platform}.tar.gz"
tar -xzf "${temp}/openapi-changes.tar.gz" -C "${temp}"

if [ -f "/opt/openapi-changes" ]; then
  echo "Removing old openapi-changes installation..."
  sudo rm -rf /opt/openapi-changes
fi

if [ -L "/usr/local/bin/openapi-changes" ] || [ -f "/usr/local/bin/openapi-changes" ]; then
  sudo rm -rf /usr/local/bin/openapi-changes
fi

sudo mv "${temp}/openapi-changes" "/opt/openapi-changes"
sudo ln -s "/opt/openapi-changes" "/usr/local/bin/openapi-changes"
