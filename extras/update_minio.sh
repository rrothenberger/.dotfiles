#!/usr/bin/env bash

set -eo pipefail
set -u

if [ -f "/opt/minio" ]; then
  echo "Removing old minio installation..."
  sudo rm /opt/minio
fi
sudo curl -Lo "/opt/minio" https://dl.min.io/server/minio/release/linux-amd64/minio
sudo chmod +x /opt/minio
if [ -L "/usr/local/bin/minio" ] || [ -f "/usr/local/bin/minio" ]; then
  sudo rm -rf /usr/local/bin/minio
fi
sudo ln -s /opt/minio /usr/local/bin/minio
