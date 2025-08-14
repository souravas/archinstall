#!/usr/bin/env bash

# Development Environment Setup Script using mise
# Usage: dev_env.sh [node]

# Source the library functions if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/lib.sh" ]]; then
  source "${SCRIPT_DIR}/lib.sh"
else
  # Fallback functions if lib.sh isn't available
  info() { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
  warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
  error() { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
  success() { printf "\033[1;32m[DONE]\033[0m %s\n" "$*"; }
fi

# Check if mise is installed
check_mise() {
  if ! command -v mise >/dev/null 2>&1; then
    error "mise is not installed. Please install it first using your package manager."
    error "You can install it with: yay -S mise-bin"
    exit 1
  fi
}

# Setup mise if not already configured
setup_mise() {
  info "Setting up mise..."

  # Add mise to shell if not already done
  if ! grep -q 'mise activate' ~/.bashrc 2>/dev/null && ! grep -q 'mise activate' ~/.zshrc 2>/dev/null; then
    if [[ -n "$ZSH_VERSION" ]] && [[ -f ~/.zshrc ]]; then
      echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
      info "Added mise activation to ~/.zshrc"
    elif [[ -f ~/.bashrc ]]; then
      echo 'eval "$(mise activate bash)"' >> ~/.bashrc
      info "Added mise activation to ~/.bashrc"
    fi
    warn "You may need to restart your shell or run 'source ~/.bashrc' or 'source ~/.zshrc'"
  fi
}

install_node() {
  info "Installing Node.js LTS using mise..."

  check_mise
  setup_mise

  # Install Node.js LTS
  if mise use --global node@lts; then
    success "Node.js LTS installed successfully"

    # Show version
    mise exec node@lts -- node --version || true
    mise exec node@lts -- npm --version || true

    info "You can now use Node.js and npm"
    info "Consider installing global packages like: npm install -g pnpm yarn"
  else
    error "Failed to install Node.js"
    exit 1
  fi
}

# Default to installing node if no arguments provided, or handle explicit arguments
if [[ -z "$1" ]] || [[ "$1" == "node" ]]; then
  install_node
else
  error "Unknown option: $1"
  echo "Usage: dev_env.sh [node]"
  echo "If no argument is provided, Node.js will be installed by default."
  exit 1
fi
