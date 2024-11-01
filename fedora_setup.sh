#!/usr/bin/env bash

if [ -z "$HOME" ]; then
  echo '$HOME not set'
  exit 1
fi

set -eo pipefail

user_home=$HOME
install_docker=$INSTALL_DOCKER
set -u

script_path=$(dirname $(realpath "$0"))

./extras/update_nvim.sh

sudo dnf install -y zsh fzf git-all yq make automake gcc gcc-c++ kernel-devel autoconf inotify-tools readline-devel \
                    ncurses-devel ncurses-libs wxGTK-devel wxBase openssl-devel libiodbc unixODBC-devel.x86_64 \
                    erlang-odbc.x86_64 libxslt fop libyaml-devel uuid-devel pkgconfig libcurl-devel icu libicu-devel \
                    gnupg2 kitty oathtool jq libuuid-devel gnupg-pkcs11-scd pcsc-lite-ccid pcsc-tools yubikey-manager \
                    podman nss-tools

sudo dnf remove opensc
sudo systemctl enable pcscd
sudo systemctl start pcscd

flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub io.podman_desktop.PodmanDesktop

chsh -s $(which zsh)

./extras/update_direnv.sh
./extras/update_cosign.sh

./extras/update_minio.sh
./extras/update_mc.sh

if [[ -f "/etc/nginx/conf.d/minio.local.conf" ]] && [[ -L "/etc/nginx/conf.d/minio.local.conf" ]]; then
  sudo rm /etc/nginx/conf.d/minio.local.conf
fi
echo "Linking minio nginx config"
sudo ln -s "${script_path}/minio/minio.local.conf" /etc/nginx/conf.d/minio.local.conf

if [[ -f "/usr/lib/systemd/user/minio.service" ]] && [[ -L "/usr/lib/systemd/user/minio.service" ]]; then
  sudo rm /usr/lib/systemd/user/minio.service
fi
echo "Linking minio.service..."
sudo ln -s "${script_path}/minio/minio.service" /usr/lib/systemd/user/minio.service

systemctl --user daemon-reload
grep -qE "^127.0.0.1\s+minio.local\$" /etc/hosts || sudo sh -c 'echo "127.0.0.1       minio.local" >> /etc/hosts'

if [ ! -z "$install_docker" ]; then
  temp=$(mktemp -d)
  sudo dnf install -y gnome-terminal dnf-plugins-core
  echo "Install this extensions: https://extensions.gnome.org/extension/615/appindicator-support/"
  echo "Press enter to continue"
  read
  sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  curl -Lo "${temp}/docker.rpm" https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm
  sudo dnf install "${temp}/docker.rpm"
fi
