
#!/usr/bin/env bash

post_config() {
  info "Post-install configuration..."

  # Determine repo root (bootstrap sets SCRIPT_DIR to repo root already)
  local REPO_ROOT="${SCRIPT_DIR}"
  local CFG_DIR="${REPO_ROOT}/configs"

  # Hard skip for dry-run to guarantee zero side-effects
  if (( NO_ACT )); then
    info "[dry-run] post_config skipped (no changes)."
    return 0
  fi

  # Fonts cache (in case fonts were installed)
  if command -v fc-cache >/dev/null 2>&1; then
    if (( NO_ACT )); then
      info "[dry-run] Would refresh font cache (fc-cache -fv)"
    else
      info "Refreshing font cache..."
      fc-cache -fv || true
    fi
  fi

  # Git globals from config files
  if [[ -f "${CFG_DIR}/git/user.name" && -f "${CFG_DIR}/git/user.email" && -f "${CFG_DIR}/git/core.editor" ]]; then
    if (( NO_ACT )); then
      info "[dry-run] Would set git user.name/user.email/core.editor from ${CFG_DIR}/git"
    else
      info "Configuring git globals..."
      git config --global user.name  "$(<"${CFG_DIR}/git/user.name")"
      git config --global user.email "$(<"${CFG_DIR}/git/user.email")"
      git config --global core.editor "$(<"${CFG_DIR}/git/core.editor")"
    fi
  else
    warn "Git config files missing under ${CFG_DIR}/git (skipping)"
    warn "Expected files: user.name, user.email, core.editor"
  fi

  # Configure diff-so-fancy if available
  if command -v diff-so-fancy >/dev/null 2>&1; then
    if (( NO_ACT )); then
      info "[dry-run] Would configure git for diff-so-fancy"
    else
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
  fi

  # Ghostty config
  if [[ -f "${CFG_DIR}/ghostty/config" ]]; then
    if (( NO_ACT )); then
      info "[dry-run] Would install Ghostty config to ~/.config/ghostty/config"
    else
      info "Setting up Ghostty config..."
      mkdir -p "${HOME}/.config/ghostty"
      cp "${CFG_DIR}/ghostty/config" "${HOME}/.config/ghostty/config"
    fi
  else
    warn "Ghostty config missing at ${CFG_DIR}/ghostty/config"
  fi

  # Fastfetch config
  if (( NO_ACT )); then
    info "[dry-run] Would copy Fastfetch images, presets, and script to ~/.local/..."
  else
    info "Setting up Fastfetch config..."
    mkdir -p "${HOME}/.local/share/fastfetch/images" "${HOME}/.local/share/fastfetch/presets"
    cp "${CFG_DIR}/fastfetch/images/"* "${HOME}/.local/share/fastfetch/images/" 2>/dev/null || true
    cp "${CFG_DIR}/fastfetch/presets/groups.jsonc" "${HOME}/.local/share/fastfetch/presets/groups.jsonc" 2>/dev/null || true
  fi

  # Starship preset
  if command -v starship >/dev/null 2>&1; then
    if (( NO_ACT )); then
      info "[dry-run] Would generate starship preset (catppuccin-powerline)"
    else
      mkdir -p "${HOME}/.config"
      info "Setting up starship config (catppuccin-powerline)..."
      starship preset catppuccin-powerline -o "${HOME}/.config/starship.toml" || true
    fi
  else
    warn "starship not found; skipping preset."
  fi

  # Oh My Zsh (non-interactive)
  if ! [[ -d "${HOME}/.oh-my-zsh" ]]; then
    if (( NO_ACT )); then
      info "[dry-run] Would install Oh My Zsh"
    else
      info "Installing Oh My Zsh (non-interactive)..."
      export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
  fi

  # zshrc & config files
  if (( NO_ACT )); then
    info "[dry-run] Would backup existing .zshrc and copy new one + supporting zsh config files"
  else
    info "Setting up zsh config..."
    if [[ -f "${HOME}/.zshrc" ]]; then
      cp "${HOME}/.zshrc" "${HOME}/.zshrc.backup.$(date +%s)"
      info "Backed up existing .zshrc"
    fi

    # Check for .zshrc in multiple possible locations
    local zshrc_source=""
    if [[ -f "${CFG_DIR}/zsh/.zshrc" ]]; then
      zshrc_source="${CFG_DIR}/zsh/.zshrc"
    elif [[ -f "${CFG_DIR}/.zshrc" ]]; then
      zshrc_source="${CFG_DIR}/.zshrc"
    elif [[ -f "${REPO_ROOT}/.zshrc" ]]; then
      zshrc_source="${REPO_ROOT}/.zshrc"
    fi

    if [[ -n "$zshrc_source" ]]; then
      cp "$zshrc_source" "${HOME}/.zshrc"
      info "Copied .zshrc from $zshrc_source"
    fi

    info "Setting up zsh config files..."
    mkdir -p "${HOME}/.config/zsh"
    cp "${CFG_DIR}/zsh/omz.zsh"       "${HOME}/.config/zsh/omz.zsh"       2>/dev/null || warn "omz.zsh not found"
    cp "${CFG_DIR}/zsh/aliases.zsh"   "${HOME}/.config/zsh/aliases.zsh"   2>/dev/null || warn "aliases.zsh not found"
    cp "${CFG_DIR}/zsh/functions.zsh" "${HOME}/.config/zsh/functions.zsh" 2>/dev/null || warn "functions.zsh not found"
    cp "${CFG_DIR}/zsh/webapp.zsh"    "${HOME}/.config/zsh/webapp.zsh"    2>/dev/null || warn "webapp.zsh not found"
  fi

  # Install Node.js using nvm (after zsh config is set up)
  if (( NO_ACT )); then
    info "[dry-run] Would install Node.js LTS using nvm"
  else
    info "Installing Node.js LTS using nvm..."
    # Check if nvm package is installed
    if pacman -Qs nvm >/dev/null 2>&1; then
      # Source nvm initialization script directly
      if [[ -f "/usr/share/nvm/init-nvm.sh" ]]; then
        source /usr/share/nvm/init-nvm.sh
        if command -v nvm >/dev/null 2>&1; then
          nvm install node || warn "Failed to install Node.js via nvm"
        else
          warn "nvm function not available after sourcing init script"
        fi
      else
        warn "nvm init script not found at /usr/share/nvm/init-nvm.sh"
      fi
    else
      warn "nvm package not installed; skipping Node.js installation"
    fi
  fi

  # Copy update script
  if (( NO_ACT )); then
    info "[dry-run] Would install update script to ~/.scripts/update.sh"
  else
    info "Setting up update script..."
    mkdir -p "${HOME}/.scripts"
    if [[ -f "${CFG_DIR}/scripts/update.sh" ]]; then
      cp "${CFG_DIR}/scripts/update.sh" "${HOME}/.scripts/update.sh"
      chmod +x "${HOME}/.scripts/update.sh"
    else
      warn "Update script missing at ${CFG_DIR}/scripts/update.sh"
    fi
  fi

  # Set zsh as default shell
  if command -v zsh >/dev/null 2>&1; then
    if [[ "$SHELL" != "$(command -v zsh)" ]]; then
      if (( NO_ACT )); then
        info "[dry-run] Would run: chsh -s $(command -v zsh)"
      else
        info "Attempting to set default shell to zsh (you may be prompted for password)..."
        chsh -s "$(command -v zsh)" || warn "Failed to change shell; you can run: chsh -s $(command -v zsh)"
      fi
    fi
  fi

  # Update tldr database (tealdeer)
  if command -v tldr >/dev/null 2>&1; then
    if (( NO_ACT )); then
      info "[dry-run] Would update tldr database"
    else
      info "Updating tldr database..."
      tldr --update || warn "Failed to update tldr database"
    fi
  else
    warn "tldr not found; skipping database update"
  fi

  # Enable fstrim timer for SSD maintenance
  if (( NO_ACT )); then
    info "[dry-run] Would enable and start fstrim.timer"
  else
    info "Enabling and starting weekly fstrim timer for SSD maintenance..."
    sudo systemctl enable --now fstrim.timer || warn "Failed to enable fstrim.timer"
  fi

  # Desktop application entries & icons bundled in repo
  local APPS_SRC_DIR="${CFG_DIR}/applications"
  local ICONS_SRC_DIR="${CFG_DIR}/icons"
  if [[ -d "$APPS_SRC_DIR" ]]; then
    local LOCAL_APPS_DIR="${HOME}/.local/share/applications"
    local LOCAL_ICONS_DIR="${HOME}/.local/share/icons"
    if (( NO_ACT )); then
      info "[dry-run] Would install desktop entries from $APPS_SRC_DIR to $LOCAL_APPS_DIR"
    else
      mkdir -p "$LOCAL_APPS_DIR" "$LOCAL_ICONS_DIR"
      for desktop in "$APPS_SRC_DIR"/*.desktop; do
        [[ -f "$desktop" ]] || continue
        cp "$desktop" "$LOCAL_APPS_DIR/"
      done
      if [[ -d "$ICONS_SRC_DIR" ]]; then
        cp "$ICONS_SRC_DIR"/* "$LOCAL_ICONS_DIR/" 2>/dev/null || true
      fi
      update-desktop-database "$LOCAL_APPS_DIR" 2>/dev/null || true
    fi
  fi

  # Install web applications
  if (( NO_ACT )); then
    info "[dry-run] Would install defined web applications via webapp-install"
  else
    info "Installing web applications..."
    # Source the webapp function
    source "${HOME}/.config/zsh/webapp.zsh" 2>/dev/null || true
    if command -v webapp-install >/dev/null 2>&1; then
      webapp-install "ChatGPT" https://chatgpt.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png || warn "Failed to install ChatGPT webapp"
      webapp-install "YouTube" https://youtube.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png || warn "Failed to install YouTube webapp"
      webapp-install "Notion" https://notion.so/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/notion.png || warn "Failed to install Notion webapp"
      webapp-install "WhatsApp" https://web.whatsapp.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/whatsapp.png || warn "Failed to install WhatsApp webapp"
      webapp-install "Reddit" https://www.reddit.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/reddit.png || warn "Failed to install Reddit webapp"
      webapp-install "Gmail" https://mail.google.com/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/gmail.png || warn "Failed to install Gmail webapp"
    else
      warn "webapp-install function not available; skipping webapp installation"
    fi
  fi

  # Open JetBrains Toolbox if installed
  if command -v jetbrains-toolbox >/dev/null 2>&1; then
    if (( NO_ACT )); then
      info "[dry-run] Would open JetBrains Toolbox in background"
    else
      info "Opening JetBrains Toolbox in background..."
      # Start JetBrains Toolbox in the background and detach from terminal
      nohup jetbrains-toolbox >/dev/null 2>&1 & disown
      info "JetBrains Toolbox opened. You can manually install PyCharm and other IDEs."
    fi
  fi

  success "Post-install configuration complete."
}
