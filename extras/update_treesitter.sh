#!/usr/bin/env bash

set -eo pipefail
set -u

temp=$(mktemp -d)
trap "rm -r $temp" EXIT

if [ -f "/opt/tree-sitter" ]; then
  echo "Removing old tree-sitter installation..."
  sudo rm -f /opt/tree-sitter
fi

curl -Lo "${temp}/tree-sitter.gz" https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
gzip -d "${temp}/tree-sitter.gz" -c > "${temp}/tree-sitter"
chmod +x "${temp}/tree-sitter"

if [ -d "/opt/tree-sitter" ]; then
  echo "Removing old tree-sitter installation..."
  sudo rm -f /opt/tree-sitter
fi

if [ -L "/usr/local/bin/tree-sitter" ] || [ -f "/usr/local/bin/tree-sitter" ]; then
  sudo rm -f /usr/local/bin/tree-sitter
fi

sudo mv "${temp}/tree-sitter" "/opt/tree-sitter"
sudo ln -s "/opt/tree-sitter" "/usr/local/bin/tree-sitter"
