#!/usr/bin/env bash
# SSH key setup helper (invoked when --ssh flag passed to bootstrap)
set -euo pipefail

# If pretty output helpers not defined (standalone run), source lib.sh from repo root
if ! declare -F info >/dev/null 2>&1; then
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/scripts/lib.sh" || true
fi

ssh_setup() {
  info "SSH setup starting..."

  # Determine email from git config if available
  GIT_EMAIL="$(git config --global user.email || echo '')"
  KEY_EMAIL="${GIT_EMAIL:-archinstall@$(hostname)}"

  # Choose key type & path
  local key_type="ed25519"
  local key_comment="${KEY_EMAIL}"
  local key_dir="${HOME}/.ssh"
  local key_file="${key_dir}/id_${key_type}"

  mkdir -p "${key_dir}"
  chmod 700 "${key_dir}"

  if [[ -f "${key_file}" ]]; then
    info "SSH key already exists at ${key_file} (skipping generation)."
  else
    info "Generating new ${key_type} SSH key..."
    ssh-keygen -t "${key_type}" -C "${key_comment}" -f "${key_file}" -N "" < /dev/null
  fi

  # Ensure agent running and key added
  if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
    info "Starting ssh-agent..."
    eval "$(ssh-agent -s)" || warn "Failed to start ssh-agent"
  fi

  if ssh-add -l 2>/dev/null | grep -q "${key_file}" || ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "${key_file}.pub" 2>/dev/null | awk '{print $2}')"; then
    info "Key already added to agent."
  else
    ssh-add "${key_file}" || warn "Failed to add key to agent"
  fi

  # Offer to copy public key to clipboard if xclip/wl-copy exists
  local pubkey_content
  pubkey_content="$(<"${key_file}.pub")"

  if command -v wl-copy >/dev/null 2>&1; then
    printf "%s" "${pubkey_content}" | wl-copy
    info "Public key copied to clipboard (wayland)."
  elif command -v xclip >/dev/null 2>&1; then
    printf "%s" "${pubkey_content}" | xclip -selection clipboard
    info "Public key copied to clipboard (X11)."
  else
    info "Install xclip or wl-clipboard for automatic clipboard copy."
  fi

  cat <<EOF
========================================
Add this SSH public key to your Git hosting provider:

${pubkey_content}

GitHub: https://github.com/settings/keys
GitLab: https://gitlab.com/-/profile/keys
========================================
EOF

  success "SSH setup complete."
}
