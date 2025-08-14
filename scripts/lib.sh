
#!/usr/bin/env bash

# Pretty output
info()    { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
warn()    { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
error()   { printf "\033[1;31m[ERR ]\033[0m %s\n" "$*" >&2; }
success() { printf "\033[1;32m[DONE]\033[0m %s\n" "$*"; }

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
  sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
  if grep -q '^#ParallelDownloads' /etc/pacman.conf; then
    sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' /etc/pacman.conf
  elif ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
    echo "ParallelDownloads = 10" | sudo tee -a /etc/pacman.conf >/dev/null
  fi
  sudo pacman -Sy --noconfirm
}

ensure_base_tools() {
  info "Ensuring base tools (git curl base-devel)..."
  sudo pacman -S --needed --noconfirm git curl base-devel
}

ensure_yay() {
  if command -v yay >/dev/null 2>&1; then
    info "yay is already installed."
    return
  fi
  info "Installing yay (AUR helper)..."
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  pushd "$tmpdir" >/dev/null
  # Prefer yay-bin to avoid building go toolchain
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  popd >/dev/null
  success "yay installed."
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
    sudo pacman -S --needed --noconfirm "$pkg"
  fi
}

install_aur_pkg() {
  local pkg="$1"
  if is_installed "$pkg"; then
    info "AUR  ✓  $pkg"
  else
    info "AUR  →  $pkg"
    yay -S --needed --noconfirm "$pkg"
  fi
}
