
#!/usr/bin/env bash

post_config() {
  info "Post-install configuration..."

  # Fonts cache (in case fonts were installed)
  if command -v fc-cache >/dev/null 2>&1; then
    info "Refreshing font cache..."
    fc-cache -fv || true
  fi

  # Git globals from config files
  info "Configuring git globals..."
  git config --global user.name "$(cat "${SCRIPT_DIR}/../configs/git/user.name")"
  git config --global user.email "$(cat "${SCRIPT_DIR}/../configs/git/user.email")"
  git config --global core.editor "$(cat "${SCRIPT_DIR}/../configs/git/core.editor")"

  # Ghostty config
  info "Setting up Ghostty config..."
  mkdir -p "${HOME}/.config/ghostty"
  cp "${SCRIPT_DIR}/../configs/ghostty/config" "${HOME}/.config/ghostty/config"

  # Starship preset
  mkdir -p "${HOME}/.config"
  if command -v starship >/dev/null 2>&1; then
    info "Writing starship preset (catppuccin-powerline)..."
    if [[ ! -f "${HOME}/.config/starship.toml" ]]; then
      starship preset catppuccin-powerline -o "${HOME}/.config/starship.toml" || true
    else
      warn "~/.config/starship.toml exists; skipping preset."
    fi
  else
    warn "starship not found; skipping preset (it will be available after next run)."
  fi

  # Oh My Zsh (non-interactive)
  if ! [[ -d "${HOME}/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh (non-interactive)..."
    export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # Oh My Zsh plugins
  export ZSH="${HOME}/.oh-my-zsh"
  export ZSH_CUSTOM="${ZSH_CUSTOM:-${ZSH}/custom}"
  mkdir -p "${ZSH_CUSTOM}/plugins"
  if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
    info "Installing zsh-autosuggestions..."
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  fi
  if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
    info "Installing zsh-syntax-highlighting..."
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  fi

  # Copy zshrc (backup existing)
  info "Setting up zsh config..."
  if [[ -f "${HOME}/.zshrc" ]]; then
    cp "${HOME}/.zshrc" "${HOME}/.zshrc.backup.$(date +%s)"
  fi
  cp "${SCRIPT_DIR}/../configs/zsh/.zshrc" "${HOME}/.zshrc"

  # Copy update script
  info "Setting up update script..."
  mkdir -p "${HOME}/.scripts"
  cp "${SCRIPT_DIR}/../configs/scripts/update.sh" "${HOME}/.scripts/update.sh"
  chmod +x "${HOME}/.scripts/update.sh"

  # Set zsh as default shell
  if command -v zsh >/dev/null 2>&1; then
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
      info "Attempting to set default shell to zsh (you may be prompted for password)..."
      chsh -s "$(command -v zsh)" || warn "Failed to change shell; you can run: chsh -s $(command -v zsh)"
    fi
  fi

  success "Post-install configuration complete."
}
