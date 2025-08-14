#!/usr/bin/env zsh
# Oh My Zsh configuration
# This file contains Oh My Zsh settings and plugin configurations

# Oh My Zsh base configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Oh My Zsh plugins
# Note: zsh-autosuggestions and zsh-syntax-highlighting are installed via package manager
# and should be sourced directly rather than through Oh My Zsh plugins
plugins=(
    git
    git-prompt
    python
)

# Load Oh My Zsh
if [ -s "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# Load plugins installed via package manager
# zsh-autosuggestions
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting (should be loaded last)
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
