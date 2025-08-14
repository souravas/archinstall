
# Source Oh My Zsh configuration
source "${ZDOTDIR:-$HOME}/.config/zsh/omz.zsh"

# Source custom aliases and functions
source "${ZDOTDIR:-$HOME}/.config/zsh/aliases.zsh"
source "${ZDOTDIR:-$HOME}/.config/zsh/functions.zsh"

# Paths
export PATH="$HOME/.local/bin:$PATH"

# Prompts
fortune | cowsay -f stegosaurus | lolcat

# Init Scripts
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Set vs code as default
export VISUAL="code --wait"
export EDITOR="code --wait"
