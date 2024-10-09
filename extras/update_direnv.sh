#!/usr/bin/env bash

set -eo pipefail
set -u

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
