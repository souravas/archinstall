
#!/usr/bin/env bash
set -euo pipefail

NO_ACT=0
DO_SSH=0
for arg in "$@"; do
	case "$arg" in
		--dry-run|-n) NO_ACT=1; shift ;;
		--ssh|--with-ssh) DO_SSH=1; shift ;;
		*) ;; # ignore unknown for now
	esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/scripts/lib.sh"
source "${SCRIPT_DIR}/scripts/install_from_lists.sh"
source "${SCRIPT_DIR}/scripts/post_config.sh"

require_arch
require_sudo
pacman_tune
ensure_base_tools
ensure_yay

# Install from unified lists (auto-detect repo vs AUR per package)
install_from_lists "${SCRIPT_DIR}/lists"

# Run Docker setup script (copied from omarchy) to ensure daemon config & group membership
if ! (( NO_ACT )); then
	if [[ -f "${SCRIPT_DIR}/scripts/docker.sh" ]]; then
		source "${SCRIPT_DIR}/scripts/docker.sh"
	else
		warn "docker.sh script missing; skipping Docker setup"
	fi
else
	info "[dry-run] Would run docker.sh setup script"
fi

# Print failure summary (if any)
if (( NO_ACT )); then
	info "Dry-run complete (no changes made)."
else
	if (( ${#FAILED_REPO_PKGS[@]} > 0 || ${#FAILED_AUR_PKGS[@]} > 0 )); then
		warn "Some packages failed to install:"
		(( ${#FAILED_REPO_PKGS[@]} )) && warn "  Repo: ${FAILED_REPO_PKGS[*]}"
		(( ${#FAILED_AUR_PKGS[@]} )) && warn "  AUR : ${FAILED_AUR_PKGS[*]}"
	else
		success "All package installs succeeded."
	fi
fi

# Run post-install user configs (zsh, starship, ghostty, git, etc.) only if not dry-run
if ! (( NO_ACT )); then
	post_config
else
	info "Skipping post_config during dry-run."
fi

# Optional SSH setup (after git config so email is available)
if (( DO_SSH )); then
	if (( NO_ACT )); then
		info "[dry-run] Skipping ssh key setup."
	else
		source "${SCRIPT_DIR}/scripts/ssh_setup.sh"
		ssh_setup
	fi
fi

# Verify essential commands are available
verify_installation

success "All done! Log out/in (or chsh to zsh) to activate shell changes."
