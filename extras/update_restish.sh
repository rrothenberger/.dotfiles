#!/usr/bin/env bash

set -eo pipefail
set -u

platform="linux-amd64"
if [[ "$(uname -s)" == "Darwin" ]];  then
  platform="macos_x86_64"
  if [[ "$(uname -p)" == "arm" ]]; then
    platform="macos_arm64"
  fi
fi

temp=$(mktemp -d)
trap "rm -r $temp" EXIT

url=$(curl https://api.github.com/repos/rest-sh/restish/releases | jq -r '.[].assets | map ({name: .name, url: .browser_download_url}).[] | select (.name | test("'$platform'"))' | jq -rn '[inputs][0].url')

curl -Lo "${temp}/restish.tar.gz" "$url"
tar -xzf "${temp}/restish.tar.gz" -C "${temp}"

if [ -f "/opt/restish" ]; then
  echo "Removing old restish installation..."
  sudo rm -rf /opt/restish
fi

if [ -L "/usr/local/bin/restish" ] || [ -f "/usr/local/bin/restish" ]; then
  sudo rm -rf /usr/local/bin/restish
fi

sudo mv "${temp}/restish" "/opt/restish"
sudo ln -s "/opt/restish" "/usr/local/bin/restish"
