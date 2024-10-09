#!/usr/bin/env bash

set -eo pipefail
set -u

if [ -f "/opt/cosign" ]; then
  echo "Removing old cosign installation..."
  sudo rm /opt/cosign
fi
sudo curl -Lo "/opt/cosign" https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
sudo chmod +x /opt/cosign
if [ -L "/usr/local/bin/cosign" ] || [ -f "/usr/local/bin/cosign" ]; then
  sudo rm /usr/local/bin/cosign
fi
sudo ln -s /opt/cosign /usr/local/bin/cosign
