
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

  # Configure diff-so-fancy if available
  if command -v diff-so-fancy >/dev/null 2>&1; then
    info "Configuring git to use diff-so-fancy..."
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    git config --global interactive.diffFilter "diff-so-fancy --patch"
    git config --global color.ui true
    git config --global color.diff-highlight.oldNormal "red bold"
    git config --global color.diff-highlight.oldHighlight "red bold 52"
    git config --global color.diff-highlight.newNormal "green bold"
    git config --global color.diff-highlight.newHighlight "green bold 22"
    git config --global color.diff.meta "11"
    git config --global color.diff.frag "magenta bold"
    git config --global color.diff.func "146 bold"
    git config --global color.diff.commit "yellow bold"
    git config --global color.diff.old "red bold"
    git config --global color.diff.new "green bold"
    git config --global color.diff.whitespace "red reverse"
  fi

  # Ghostty config
  info "Setting up Ghostty config..."
  mkdir -p "${HOME}/.config/ghostty"
  cp "${SCRIPT_DIR}/../configs/ghostty/config" "${HOME}/.config/ghostty/config"

  # Fastfetch config
  info "Setting up Fastfetch config..."
  mkdir -p "${HOME}/.local/share/fastfetch/images"
  mkdir -p "${HOME}/.local/share/fastfetch/presets"
  cp "${SCRIPT_DIR}/../configs/fastfetch/images/"* "${HOME}/.local/share/fastfetch/images/"
  cp "${SCRIPT_DIR}/../configs/fastfetch/presets/groups.jsonc" "${HOME}/.local/share/fastfetch/presets/groups.jsonc"
  mkdir -p "${HOME}/.local/bin"
  cp "${SCRIPT_DIR}/../configs/fastfetch/fastfetch.sh" "${HOME}/.local/bin/fastfetch"
  chmod +x "${HOME}/.local/bin/fastfetch"

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

  # Copy zsh config files to ~/.config/zsh/
  info "Setting up zsh config files..."
  mkdir -p "${HOME}/.config/zsh"
  cp "${SCRIPT_DIR}/../configs/zsh/omz.zsh" "${HOME}/.config/zsh/omz.zsh"
  cp "${SCRIPT_DIR}/../configs/zsh/aliases.zsh" "${HOME}/.config/zsh/aliases.zsh"
  cp "${SCRIPT_DIR}/../configs/zsh/functions.zsh" "${HOME}/.config/zsh/functions.zsh"
  cp "${SCRIPT_DIR}/../configs/zsh/webapp.zsh" "${HOME}/.config/zsh/webapp.zsh"

  # Setup NVM and install latest Node.js
  if command -v nvm >/dev/null 2>&1; then
    info "Setting up NVM and installing latest Node.js..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Install latest LTS version of Node.js
    nvm install --lts
    nvm use --lts
    nvm alias default node
    info "Node.js $(node --version) installed via NVM"
  else
    warn "nvm not found; skipping Node.js installation"
  fi

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

  # Enable fstrim timer for SSD maintenance
  info "Enabling weekly fstrim timer for SSD maintenance..."
  sudo systemctl enable fstrim.timer || warn "Failed to enable fstrim.timer"

  # Install web applications
  info "Installing web applications..."
  # Source the webapp function
  source "${HOME}/.config/zsh/webapp.zsh" 2>/dev/null || true

  # Install webapps
  if command -v webapp-install >/dev/null 2>&1; then
    webapp-install "ChatGPT" https://chatgpt.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png || warn "Failed to install ChatGPT webapp"
    webapp-install "YouTube" https://youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png || warn "Failed to install YouTube webapp"
    webapp-install "Notion" https://notion.so/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/notion.png || warn "Failed to install Notion webapp"
  else
    warn "webapp-install function not available; skipping webapp installation"
  fi

  success "Post-install configuration complete."
}
