#!/usr/bin/env zsh
# Custom aliases for zsh
# This file contains all custom aliases that can be sourced by .zshrc

# System
alias update='sudo ~/.scripts/update.sh'

# File system
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd='z'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias n='nvim'
alias g='git'
alias d='docker'
alias lzg='lazygit'
alias lzd='lazydocker'
alias lg='lazygit'
alias lz='lazygit'
alias cat='bat'

# Git
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gs='git status'
alias gcn='git commit --no-verify -m "c"'

# fzf
alias ff="fd --ignore-file ~/.config/fd/ignore . --type f | fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}'"
alias fff="fd --ignore-file ~/.config/fd/ignore . --type f | fzf --preview='bat --color=always {}' --exit-0 | xargs -I {} code \"{}\""
alias gcf='git checkout $(git branch | fzf)'
alias gbf='git checkout $(git branch | fzf)'
alias cdf='cd $(find . -type d | fzf)'

# yt-dlp
alias ytd='yt-dlp -f "bv*[height=1080]+ba/b"'
alias ytdp='yt-dlp -f "bv*[height=1080]+ba/b" -o "%(playlist_index)03d - %(title)s.%(ext)s"'
alias ytdpl='yt-dlp -f "bv*[height=720]+ba/b" -o "%(playlist_index)03d - %(title)s.%(ext)s"'
alias ytda='yt-dlp -f bestaudio -x --audio-format mp3 --audio-quality 0'

# Compression
alias decompress="tar -xzf"

