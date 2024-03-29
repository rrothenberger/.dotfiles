#!/usr/bin/env bash

set -eo pipefail

if [ -z "$HOME" ]; then
  echo 'ERROR: $HOME is not set'
  exit 1
fi

user_home=$HOME
install_asdf=$INSTALL_ASDF

set -u

function checkIfGNUReadlink() {
  local test_dir=$(mktemp -d)
  mkdir -p $test_dir

  touch "$test_dir/good"
  ln -s  "$test_dir/good" "$test_dir/bad"
  ln -s  "$test_dir/bad" "$test_dir/test"

  [ "$(readlink -f "$test_dir/test")" == "$test_dir/good" ]
}
command -v readlink >/dev/null && readlink_exists=true || readlink_exists=false
command -v realpath >/dev/null && realpath_exists=true || realpath_exists=false

if ! $realpath_exists && ! $readlink_exists; then
  echo "ERROR: missing readlink or realpath"
  exit 1
fi
checkIfGNUReadlink && gnu_readlink=true || gnu_readlink=false

function resolveLink() {
  if $realpath_exists; then
    realpath "$1"
  elif $gnu_readlink; then
    readlink -f "$1"
  else
    # So why this even exists? Well, if you have GNU readlink you can
    # just do the same as above:
    # readlink -f "$1"
    # But if for whatever reason you are called "Apple", you might have
    # decided to not use GNU readlink - so now we have the manually
    # resolve links... 

    cd -- $(dirname "$1")
    local target_file=$(basename "$1")

    while [ -L "$target_file" ]; do
      target_file=$(readlink "$target_file")
      cd -- $(dirname "$target_file")
      target_file=$(basename "$target_file")
    done

    echo "$(pwd -P)/$target_file"
  fi
}

function resolveAbsolutePath() {
  if $realpath_exists; then
    realpath "$1"
  elif [ -L "$1" ]; then
    resolveLink "$1"
  else
    cd -- "$(dirname "$1")" >/dev/null 2>&-
    echo "$(pwd -P)/$(basename "$1")"
  fi
}

start_time=$(date +%s)
script_path=$(dirname $(resolveAbsolutePath "$0"))
backup_path="${script_path}/backup/${start_time}/"
config_root_path="${script_path}/root"

function checkIfCommandExists() {
  if ! command -v "$1" >/dev/null; then
    echo "ERROR: $1 is not installed"
    exit 1
  fi
}

# Check if core dependencies are installed
checkIfCommandExists 'curl'
checkIfCommandExists 'git'
checkIfCommandExists 'zsh'
checkIfCommandExists 'nvim'
checkIfCommandExists 'tmux'
checkIfCommandExists 'gpg2'
checkIfCommandExists 'fzf'

# Check dependencies that script can install by itself
if [ ! -d "$user_home/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

function linkConfiguration() {
  local file=$1
  local dest="${user_home}/${file}"
	if [ ! -z "$2" ]; then
		dest=$2
	fi

  if [ -f "$dest" ] || [ -d "$dest" ]; then
    if [ -L "$dest" ]; then
      local src=$(resolveLink "$dest")
      if [ "$src" == "$config_root_path/$file" ]; then
        echo "Skipping $dest, already linked"
        return
      fi

      local backup_destination="${backup_path}${file}"
      echo "Backing up $dest to $backup_destination"
      mkdir -p "$(dirname "$backup_destination")"
      ln -s "$src" "$backup_destination"
      rm "$dest"
    else
      local backup_destination="${backup_path}${file}"
      echo "Backing up $dest to $backup_destination"
      mkdir -p "$(dirname "$backup_destination")"
      mv "$dest" "$backup_destination"
    fi
  fi

  echo "Linking $file to $dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$config_root_path/$file" "$dest"
}

if [ ! -d "$user_home/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$user_home/.oh-my-zsh/custom/themes/powerlevel10k"
fi

linkConfiguration ".zshrc" 
linkConfiguration ".gitconfig" 
linkConfiguration ".gitignore_global" 
linkConfiguration "work/.gitconfig"
linkConfiguration ".gnupg/gpg-agent.conf"
linkConfiguration ".tmux.conf"
linkConfiguration ".config/nvim"
linkConfiguration ".tool-versions"

linkConfiguration ".local/bin/otp"

if [ ! -d "$user_home/.tmux/plugins/tpm" ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm "$user_home/.tmux/plugins/tpm"
fi

echo "Importing public keys into GPG for yubikeys usage..."

ls "${script_path}/keys" | while read -r file; do
  gpg2 --import "${script_path}/keys/${file}"
done
gpg2 --import-ownertrust "${script_path}/ownertrust.txt"

if [ ! -z "$install_asdf" ]; then
  if ! command -v asdf >/dev/null; then
    echo "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$user_home/.asdf" --branch v0.14.0

    source $user_home/.asdf/asdf.sh
  fi

  asdf update
	asdf plugin update --all

  echo "Installing asdf plugins..."
	cat "${config_root_path}/.tool-versions" | cut -d' ' -f1 | grep -e '^[^#]' | while read -r line; do asdf plugin add "$line"; done

  echo "Installing dependencies from asdf..."
  asdf install
fi

echo "Setting git remote to ssh"
git remote set-url origin git@github.com:rafalrothenberger/.dotfiles.git

echo "Done! Reboot now to enable all changes"

