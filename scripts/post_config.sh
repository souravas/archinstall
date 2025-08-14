
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
    info "Setting up starship config (catppuccin-powerline)..."
    starship preset catppuccin-powerline -o "${HOME}/.config/starship.toml" || true
  else
    warn "starship not found; skipping preset."
  fi

  # Oh My Zsh (non-interactive)
  if ! [[ -d "${HOME}/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh (non-interactive)..."
    export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
