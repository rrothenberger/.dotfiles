#!/usr/bin/env bash

set -eo pipefail

if [ -z "$HOME" ]; then
  echo '$HOME not set'
  exit 1
fi

exec_path=$0
winuser=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe '$env:UserName')
winuser=${winuser//$'\r'}
linux_home=$HOME

set -u

if [ -z "$winuser" ]; then
  echo 'No Windows user found'
  exit 1
fi

app_home="/mnt/c/Users/$winuser/AppData/Roaming"
script_path=$(cd -- "$(dirname $exec_path)" >/dev/null 2>&1 ; pwd -P)
start_time=$(date +%s)

echo "Current user: $winuser"
echo "AppData/Roaming: $app_home"
echo "Script path: $script_path"
echo "Start time: $start_time"

echo

sudo apt install -y socat

if [ ! -d "$app_home" ]; then
  echo 'No AppData/Roaming directory found'
  exit 1
fi

if [ ! -d "$app_home/gnupg" ]; then
  echo "No $app_home/gnupg directory found, install gnupg in host machine:"
  echo "https://gnupg.org/download/ - download gpg4win"
  exit 1
fi

if [ ! -d "/mnt/c/Program Files/PuTTy" ]; then
  echo "No PuTTy directory found, install PuTTy in host machine:"
  echo "https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html"
  exit 1
fi

temp=$(mktemp -d)
trap "rm -r $temp" EXIT

if [ ! -d "$app_home/wsl2-ssh-pageant" ]; then
  mkdir -p "$app_home/wsl2-ssh-pageant"
  curl -Lo "${app_home}/wsl2-ssh-pageant/wsl2-ssh-pageant.exe" https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/latest/download/wsl2-ssh-pageant.exe
else
  echo "wsl2-ssh-pageant already installed in $app_home/wsl2-ssh-pageant"
fi

mkdir -p "$linux_home/.wsl2"
if [ -f "$linux_home/.wsl2/wsl2-ssh-pageant.exe" ] || [ -L "$linux_home/.wsl2/wsl2-ssh-pageant.exe" ]; then
  rm "$linux_home/.wsl2/wsl2-ssh-pageant.exe"
fi
ln -s "$app_home/wsl2-ssh-pageant/wsl2-ssh-pageant.exe" "$linux_home/.wsl2/wsl2-ssh-pageant.exe"

if [ -f "$app_home/gnupg/gpg.conf" ]; then
  echo "Existing gpg.conf found in $app_home/gnupg, backing up to $app_home/gnupg/gpg.conf.bak.${start_time}"
  mv "$app_home/gnupg/gpg.conf" "$app_home/gnupg/gpg.conf.bak.${start_time}"
fi
cp "$script_path/wsl/app_data_roaming/gnupg/gpg.conf" "$app_home/gnupg/"

if [ -f "$app_home/gnupg/gpg-agent.conf" ]; then
  echo "Existing gpg-agent.conf found in $app_home/gnupg, backing up to $app_home/gnupg/gpg-agent.conf.bak.${start_time}"
  mv "$app_home/gnupg/gpg-agent.conf" "$app_home/gnupg/gpg-agent.conf.bak.${start_time}"
fi
cp "$script_path/wsl/app_data_roaming/gnupg/gpg-agent.conf" "$app_home/gnupg/"

echo
echo "Done, you can now restart your machine and run $(dirname $0)/apt_setup.sh"
