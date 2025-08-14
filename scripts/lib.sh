
#!/usr/bin/env bash

# Pretty output
info()    { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()    { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error()   { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
success() { printf "\033[1;32m[DONE]\033[0m %s\n" "$*"; }
verbose() { (( ${VERBOSE:-0} )) && printf "\033[1;36m[VERB]\033[0m %s\n" "$*" || true; }

# Global flags
: "${NO_ACT:=0}"     # if set to 1, perform a dry-run (no installs)
: "${VERBOSE:=0}"    # if set to 1, enable verbose output

# Failure tracking
FAILED_REPO_PKGS=()
FAILED_AUR_PKGS=()

require_arch() {
  if ! command -v pacman >/dev/null 2>&1; then
    error "This script is for Arch Linux. pacman not found."; exit 1
  fi
}

require_sudo() {
  if ! sudo -v; then
    error "We need sudo privileges to install packages."; exit 1
  fi
}

pacman_tune() {
  info "Tuning pacman (Color + ParallelDownloads)..."

  # Enable Color
  if grep -q '^#Color' /etc/pacman.conf; then
    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    info "Enabled pacman color output"
  elif ! grep -q '^Color' /etc/pacman.conf; then
    echo "Color" | sudo tee -a /etc/pacman.conf >/dev/null
    info "Added Color option to pacman.conf"
  fi

  # Set ParallelDownloads
  if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
    sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
    info "Enabled parallel downloads (10)"
  elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
    echo "ParallelDownloads = 10" | sudo tee -a /etc/pacman.conf >/dev/null
    info "Added ParallelDownloads = 10 to pacman.conf"
  fi

  info "Updating package database..."
  sudo pacman -Sy --noconfirm || warn "Failed to update package database"
}

ensure_base_tools() {
  info "Ensuring base tools (git curl base-devel)..."
  sudo pacman -S --needed --noconfirm git curl base-devel
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    info "yay is already installed."
    return 0
  fi

  info "Installing yay (AUR helper)..."
  local tmpdir
  tmpdir="$(mktemp -d)"

  # Ensure cleanup on exit
  cleanup_yay() {
    [[ -d "$tmpdir" ]] && rm -rf "$tmpdir"
  }
  trap cleanup_yay EXIT

  if ! pushd "$tmpdir" >/dev/null; then
    error "Failed to change to temporary directory"
    return 1
  fi

  # Clone and build yay-bin (faster than building from source)
  if ! git clone --depth 1 https://aur.archlinux.org/yay-bin.git; then
    error "Failed to clone yay-bin repository"
    popd >/dev/null
    return 1
  fi

  if ! cd yay-bin; then
    error "Failed to enter yay-bin directory"
    popd >/dev/null
    return 1
  fi

  if ! makepkg -si --noconfirm; then
    error "Failed to build and install yay"
    popd >/dev/null
    return 1
  fi

  popd >/dev/null

  # Verify installation
  if command -v yay >/dev/null 2>&1; then
    success "yay installed successfully."
    return 0
  else
    error "yay installation failed verification"
    return 1
  fi
}

is_installed() {
  local pkg="$1"
  pacman -Q "$pkg" &>/dev/null
}

install_repo_pkg() {
  local pkg="$1"
  if is_installed "$pkg"; then
    info "repo ✓  $pkg"
  else
    info "repo →  $pkg"
    if (( NO_ACT )); then
      verbose "(dry-run) pacman -S --needed --noconfirm $pkg"
    else
      verbose "Running: sudo pacman -S --needed --noconfirm $pkg"
      if ! sudo pacman -S --needed --noconfirm "$pkg"; then
        FAILED_REPO_PKGS+=("$pkg")
        error "Failed repo install: $pkg"
        return 1
      fi
    fi
  fi
  return 0
}

install_aur_pkg() {
  local pkg="$1"
  if is_installed "$pkg"; then
    info "AUR  ✓  $pkg"
  else
    info "AUR  →  $pkg"
    if (( NO_ACT )); then
      verbose "(dry-run) yay -S --needed --noconfirm $pkg"
    else
      verbose "Running: yay -S --needed --noconfirm $pkg"
      if ! yay -S --needed --noconfirm "$pkg"; then
        FAILED_AUR_PKGS+=("$pkg")
        error "Failed AUR install: $pkg"
        return 1
      fi
    fi
  fi
  return 0
}

verify_installation() {
  info "Verifying installation..."

  local essential_commands=("git" "zsh" "starship" "code")
  local missing=()

  for cmd in "${essential_commands[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    warn "Missing essential commands: ${missing[*]}"
    return 1
  else
    success "All essential commands available"
    return 0
  fi
}
