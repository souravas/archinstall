
# Oh My Zsh base
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
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

# Alias
alias u='sudo ~/.scripts/update.sh'

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
alias docker='podman'
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
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Brightness
bright() {
  if [[ $1 =~ ^[0-9]+$ && $1 -ge 0 && $1 -le 100 ]]; then
    i2c_device=$(ddccontrol -p 2>/dev/null | grep -o 'dev:/dev/i2c-[0-9]\\+' | sed -n '2p')
    if [[ -n $i2c_device ]]; then
      sudo ddccontrol -r 0x10 -w "$1" "$i2c_device" &>/dev/null &
    else
      echo "No second active monitor detected."
    fi
  else
    echo "Please enter a valid brightness level (0-100)."
  fi
}

media_duration() {
  local sum_s=0 dur time hh mm ss total_s H M S
  for f in *; do
    [[ -f $f ]] || continue
    dur=$(mediainfo --Inform="General;%Duration/String3%" "$f")
    time=${dur%%.*}
    if [[ $time =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
      printf "%-8s  %s\n" "$time" "$f"
      IFS=: read hh mm ss <<< "$time"
      (( sum_s += 10#$hh*3600 + 10#$mm*60 + 10#$ss ))
    fi
  done
  H=$(( sum_s/3600 )); M=$(( (sum_s%3600)/60 )); S=$(( sum_s%60 ))
  printf "\\nTotal duration: %02d:%02d:%02d\\n" $H $M $S
}

add_prefix() { local prefix=$1; for f in *; do [[ -f "$f" ]] && mv -- "$f" "${prefix}${f}"; done; }
prefix_folders() {
  local count=1
  for dir in */; do
    [[ -d "$dir" ]] || continue
    prefix=$(printf "%02d - " "$count")
    for file in "$dir"*; do
      [[ -f "$file" ]] || continue
      base=$(basename "$file")
      mv -- "$file" "${dir}${prefix}${base}"
    done
    ((count++))
  done
}
unprefix_folders() {
  for dir in */; do
    [[ -d "$dir" ]] || continue
    for src in "$dir"*; do
      [[ -f "$src" ]] || continue
      filename="${src##*/}"
      case "$filename" in
        [0-9][0-9]\ -\ *)
          newname="${filename:5}"
          echo "Renaming: '$filename' -> '$newname'"
          mv -- "$src" "${dir}${newname}"
          ;;
        *) echo "Skipping: '$filename'";;
      esac
    done
  done
}

# append_suffix: append a string to every filename in the cwd (no folders, no recursion)
# Usage: add_suffix "_SUFFIX"
add_suffix() {
  suffix=$1
  if [ -z "$suffix" ]; then
    printf 'Usage: add_suffix "_SUFFIX"\\n' >&2
    return 1
  fi
  set -- *
  if [ "$#" -eq 1 ] && [ "$1" = "*" ]; then echo "No files to rename."; return 0; fi
  for file; do [ -f "$file" ] || continue; mv -- "$file" "${file}${suffix}"; done
}

remove_characters() {
  local num="$1"
  if [[ -z "$num" || ! "$num" =~ ^[0-9]+$ ]]; then echo "Usage: remove_characters <num_chars_to_remove>"; return 1; fi
  set -- *
  if [ "$#" -eq 1 ] && [ "$1" = "*" ]; then echo "No files to rename."; return 0; fi
  for file; do
    [[ -f "$file" ]] || continue
    filename="$file"
    newname="${filename:$num}"
    [[ -n "$newname" && "$newname" != "$filename" ]] || continue
    echo "Renaming: '$filename' -> '$newname'"; mv -- "$file" "$newname"
  done
}

copy_folder_structure() {
  mkdir -p _folders
  for dir in */; do [[ -d "$dir" ]] || continue; mkdir -p "_folders/${dir%/}"; done
}

# Paths
export PATH="$HOME/.local/bin:$PATH"

# Custom Directory
alias cdd='cd /mnt/c/Users/soura/Downloads'

# Prompts
fortune | cowsay -f stegosaurus | lolcat

# Init Scripts
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Set vs code as default
export VISUAL="code --wait"
export EDITOR="code --wait"
