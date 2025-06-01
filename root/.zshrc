if [[ -n "${XDG_SESSION_ID}" && "${TERM}" == "dumb" &&
        "$(ps -p $PPID -o comm=)" == "login" ]]; then
        # Running in the background login process. Do nothing.
        return
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export GIT_PERSONAL_CONFIG_DIR=$(dirname $(dirname $(readlink -n -f ~/.zshrc)))

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="powerlevel9k/powerlevel9k"
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
#POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)
#POWERLEVEL9K_MODE='nerdfont-complete'

ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)
POWERLEVEL9K_MODE='nerdfont-complete'

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitfast fzf zsh-autosuggestions direnv command-not-found colored-man-pages mix npm rails ruby)

source $ZSH/oh-my-zsh.sh

# User configuration

prompt_context(){}

alias sl="ls"
alias vim="nvim"
alias sops='EDITOR="nvim" sops'

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

export GID=$GID
export UID=$UID

export LC_ALL=en_US.UTF-8
export SSH_AUTH_SOCK="$(gpgconf --list-dirs socketdir)/S.gpg-agent.ssh"

function _setup_wsl_gpg() {
  if [ ! -f "$HOME/.wsl2/wsl2-ssh-pageant.exe" ]; then
    return
  fi

  local winuser
  winuser=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe '$env:UserName')
  winuser=${winuser//$'\r'}
  local config_path="C\:/Users/$winuser/AppData/Local/gnupg"
  local wsl2_ssh_pageant_bin="$HOME/.wsl2/wsl2-ssh-pageant.exe"
  local gpg_socket_dir=$(gpgconf --list-dirs socketdir)

  local ssh_socket="$gpg_socket_dir/S.gpg-agent.ssh"
  local gpg_socket="$gpg_socket_dir/S.gpg-agent"

  # Make sure that Host is running GPG Agent
  /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe 'gpgconf --launch gpg-agent'

  # SSH Socket
  # Removing Linux SSH socket and replacing it by link to wsl2-ssh-pageant socket
  if ! ss -a | grep -q "$ssh_socket"; then
    rm -f "$ssh_socket"
    if test -x "$wsl2_ssh_pageant_bin"; then
      (setsid nohup socat UNIX-LISTEN:"$ssh_socket,fork" EXEC:"$wsl2_ssh_pageant_bin" >/dev/null 2>&1 &)
    else
      echo >&2 "WARNING: $wsl2_ssh_pageant_bin is not executable."
    fi
  fi

  # GPG Socket
  # Removing Linux GPG Agent socket and replacing it by link to wsl2-ssh-pageant GPG socket
  if ! ss -a | grep -q "$gpg_socket"; then
    rm -rf "$gpg_socket"
    if test -x "$wsl2_ssh_pageant_bin"; then
      (setsid nohup socat UNIX-LISTEN:"$gpg_socket,fork" EXEC:"$wsl2_ssh_pageant_bin --gpgConfigBasepath ${config_path} --gpg S.gpg-agent" >/dev/null 2>&1 &)
    else
      echo >&2 "WARNING: $wsl2_ssh_pageant_bin is not executable."
    fi
  fi
}
_setup_wsl_gpg

export GPG_TTY=$(tty)

function _create_copy_of_zshrc {
    mkdir -p $HOME/.zshrc_copy
    touch $HOME/.zshrc_copy/last_hash
    local last_hash=$(cat $HOME/.zshrc_copy/last_hash)
    local current_hash=$(cat $HOME/.zshrc | sha256sum -z)
    if [ "$current_hash" != "$last_hash" ]; then
        cp $HOME/.zshrc $HOME/.zshrc_copy/$(date -u +%Y%m%d_%H%M_%s)
        printf "%s" $current_hash > $HOME/.zshrc_copy/last_hash;
        echo "Current .zshrc was backed up!"
    fi
}
_create_copy_of_zshrc

function _check_if_git_personal_config_is_commited() {
    pushd $GIT_PERSONAL_CONFIG_DIR >/dev/null 2>&1
    if [[ -n $(git status --porcelain) ]];
    then
        echo "Config has uncommited or unpushed changes!"
        echo "Config repo: $GIT_PERSONAL_CONFIG_DIR"
    fi
    popd >/dev/null 2>&1
}
_check_if_git_personal_config_is_commited

function _check_remote_git_config() {
  pushd $GIT_PERSONAL_CONFIG_DIR >/dev/null 2>&1
  trap "popd >/dev/null 2>&1" EXIT

  touch .last_sync
  touch .last_sync_commit

  local local_last_commit=$(git rev-parse HEAD)
  local last_sync=$(cat .last_sync)
  local last_sync_commit=$(cat .last_sync_commit)
  local sync_date=$(date +%D)

  if [[ "$last_sync" == "$sync_date" ]]; then
    if [[ "$last_sync_commit" != "$local_last_commit" ]]; then
      printf "Remote and local config repo are out of sync.\n"
      printf "Config repo: $GIT_PERSONAL_CONFIG_DIR\n"
    fi
    return
  fi

  printf "Checking remote config repo...\n"

  local repo_name=$(basename $(git ls-remote --get-url origin) .git)
  local username=$(dirname $(git ls-remote --get-url origin))
  if [[ "$username" == git@* ]]; then
    username=$(printf $username | cut -d":" -f 2)
  fi

  local remote_last_commit=$(curl -s "https://api.github.com/repos/${username}/${repo_name}/branches/main" | jq -r ".commit.sha")

  if [[ "$remote_last_commit" != "$local_last_commit" ]]; then
    printf "Remote and local config repo are out of sync.\n"
    printf "Config repo: $GIT_PERSONAL_CONFIG_DIR\n"
  fi

  printf $sync_date > .last_sync
  printf $remote_last_commit > .last_sync_commit
}
_check_remote_git_config

function _push_gitconfig() {
    pushd $GIT_PERSONAL_CONFIG_DIR >/dev/null 2>&-
    trap "popd >/dev/null 2>&-" EXIT
    git add .
    git commit -m "[auto] syncing settings"
    git push origin main
    [ -f ".last_sync_commit" ] && rm .last_sync_commit
    [ -f ".last_sync" ] && rm .last_sync
}

function _pull_gitconfig() {
    pushd $GIT_PERSONAL_CONFIG_DIR >/dev/null 2>&-
    trap "popd >/dev/null 2>&-" EXIT
    git pull origin main
    [ -f ".last_sync_commit" ] && rm .last_sync_commit
    [ -f ".last_sync" ] && rm .last_sync
}

function _clf_tag() {
  git tag -f -m "" $1/$(git rev-parse --abbrev-ref HEAD)
  git push -f origin $1/$(git rev-parse --abbrev-ref HEAD)
}

function _clf_tags() {
  git ls-remote --tags origin | grep "refs/tags/$1/" | grep -v "\^{}" | cut -d"/" -f4-
}

export PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"
export XDG_CONFIG_HOME="$HOME/.config"
export ERL_AFLAGS="-kernel shell_history enabled"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C $HOME/.local/bin/mc mc

function pubport() {
  ssh -N -R 50001:0.0.0.0:${1} proxy.rothenberger.dev
}

function make_me_temp() {
  temp=$(mktemp -d)
  mux "$temp"
}

if [[ ! -z $MUX_INIT_CHANNEL ]]; then
  tmux wait-for -U "$MUX_INIT_CHANNEL"
  unset MUX_INIT_CHANNEL
fi

ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# KEEP LAST!!!
export PATH=$HOME/.local/bin:$PATH
