#!/usr/bin/env zsh
# Oh My Zsh configuration
# This file contains Oh My Zsh settings and plugin configurations

# Oh My Zsh base configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Oh My Zsh plugins
# Note: The following plugins need to be installed manually:
# - zsh-autosuggestions: git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# - zsh-syntax-highlighting: git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(
    git
    git-prompt
    zsh-autosuggestions
    zsh-syntax-highlighting
    python
)

# Load Oh My Zsh
if [ -s "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
fi
