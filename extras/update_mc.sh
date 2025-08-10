#!/usr/bin/env bash

set -eo pipefail
set -u

if [ -f "/opt/mc" ]; then
  echo "Removing old mc installation..."
  sudo rm /opt/mc
fi
# Installing specific version because in newer ones they removed admin capabilities from web UI.
sudo curl -Lo "/opt/mc" https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2025-04-16T18-13-26Z
sudo chmod +x /opt/mc
if [ -L "/usr/local/bin/mc" ] || [ -f "/usr/local/bin/mc" ]; then
  sudo rm -rf /usr/local/bin/mc
fi
sudo ln -s /opt/mc /usr/local/bin/mc
