#!/usr/bin/env bash

set -eo pipefail
set -u

git submodule init
git submodule update

mkdir -p ~/.local/share/fonts/firacode
mkdir -p ~/.local/share/fonts/furacode

cp ./fonts/fonts/Fira* ~/.local/share/fonts/firacode/
cp ./fonts/fonts/Fura* ~/.local/share/fonts/furacode/

