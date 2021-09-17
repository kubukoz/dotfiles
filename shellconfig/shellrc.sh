#!/usr/bin/env bash

###
# Generic shellrc to be used by both zshrc and bashrc
###

# NOTE: problems might occur if /bin/sh is symlinked to /bin/bash
if [ -n "${BASH}" ]; then
    shell="bash"
elif [ -n "${ZSH_NAME}" ]; then
    shell="zsh"
fi

#####
# Load plugins and utilities
#####

# Load exports
source ~/.dotfiles/shellconfig/exports.sh
# start=$(date +%s.%N)

# Neofetch
if [ -x "$(command -v neofetch)" ] > /dev/null 2>&1; then
    set +m
    neofetch --disable packages term > /tmp/neofetch_output.txt &
    NEOFETCH_PID=$!
fi

# Enable autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && source /usr/local/etc/profile.d/autojump.sh # Mac
[ -f /usr/share/autojump/autojump.sh ] && source /usr/share/autojump/autojump.sh # Linux

# Wasmer
export WASMER_DIR="$HOME/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"  # This loads wasmer

# Use gitstatusd built locally if exists
# To build, run `zsh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/gitstatus/master/build.zsh)"`
if [ -f "$HOME"/.dotfiles/bin/gitstatusd-linux-$(uname -m) ]; then
    export GITSTATUS_DAEMON=$HOME/.dotfiles/bin/gitstatusd-linux-$(uname -m)
fi

# Load fzf plugin. Installed thru setup_zsh.sh
[ -f ~/.fzf.${shell} ] && source ~/.fzf.${shell}

# Kubernetes
if [ -x "$(command -v kubectl)" ] > /dev/null 2>&1; then
  source ~/.dotfiles/shellconfig/kubernetes.sh
fi

# Load iTerm2 integration
[ -f "${HOME}"/.dotfiles/shellconfig/iterm2_shell_integration.${shell} ] && source "${HOME}"/.dotfiles/shellconfig/iterm2_shell_integration."${shell}"

# Load private exports
[ -f "${HOME}"/Dropbox/Configs/exports-private.sh ] && source "${HOME}"/Dropbox/Configs/exports-private.sh

# Functions
source ~/.dotfiles/shellconfig/funcs.sh

# Load generic aliases
source ~/.dotfiles/shellconfig/aliases.sh

# Source some utilities
source "$HOME/.dotfiles/utils.sh"

# Load Mac aliases
if [ $(uname -s) = 'Darwin' ]; then
    source ~/.dotfiles/shellconfig/aliases_mac.sh
fi

# Load hub (https://github.com/github/hub)
if [ -x "$(command -v hub)" ]; then
  eval "$(hub alias -s)"
fi

# Initialize and add custom completions
_ssh_config () {
    compadd $(cat ~/.ssh/config|grep "Host " |grep -v "Host \*" |sed -e "s/^Host //g")
}

if [ -n "${BASH}" ]; then
    complete -o default -o nospace -F _ssh_config ssh
    complete -o default -o nospace -F _cs coursier
elif [ -n "${ZSH_NAME}" ]; then
    compdef _ssh_config ssh
    compdef _cs coursier
fi

#####
# These are at the end to print on user login
#####

wait $NEOFETCH_PID
\cat /tmp/neofetch_output.txt

if tmux list-sessions > /dev/null 2>&1; then
    echo ""
    echo "There are TMux sessions running:"
    echo ""
    tmux list-sessions
    echo ""
fi
# end="$(date +%s.%N)"
# runtime=$( echo "$end - $start" | bc -l )
# echo "Shellrc took $runtime seconds to load."
