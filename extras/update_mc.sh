#!/usr/bin/env bash

set -eo pipefail
set -u

if [ -f "/opt/mc" ]; then
  echo "Removing old mc installation..."
  sudo rm /opt/mc
fi
sudo curl -Lo "/opt/mc" https://dl.min.io/client/mc/release/linux-amd64/mc
sudo chmod +x /opt/mc
if [ -L "/usr/local/bin/mc" ] || [ -f "/usr/local/bin/mc" ]; then
  sudo rm -rf /usr/local/bin/mc
fi
sudo ln -s /opt/mc /usr/local/bin/mc
