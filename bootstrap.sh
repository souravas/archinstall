
#!/usr/bin/env bash
set -euo pipefail

# Initialize variables
NO_ACT=0
VERBOSE=0

# Parse arguments
for arg in "$@"; do
	case "$arg" in
		--dry-run|-n) NO_ACT=1 ;;
		--verbose|-v) VERBOSE=1 ;;
		--help|-h)
			echo "Usage: $0 [OPTIONS]"
			echo "Options:"
			echo "  -n, --dry-run    Show what would be done without making changes"
			echo "  -v, --verbose    Enable verbose output"
			echo "  -h, --help       Show this help message"
			exit 0
			;;
		*)
			echo "Unknown option: $arg" >&2
			echo "Use --help for usage information" >&2
			exit 1
			;;
	esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Export variables for child scripts
export NO_ACT VERBOSE

source "${SCRIPT_DIR}/scripts/lib.sh"
source "${SCRIPT_DIR}/scripts/install_from_lists.sh"
source "${SCRIPT_DIR}/scripts/post_config.sh"

# Validate script environment before proceeding
validate_environment() {
	verbose "Validating environment..."

	# Check required directories exist
	local required_dirs=("${SCRIPT_DIR}/scripts" "${SCRIPT_DIR}/lists" "${SCRIPT_DIR}/configs")
	for dir in "${required_dirs[@]}"; do
		if [[ ! -d "$dir" ]]; then
			error "Required directory missing: $dir"
			return 1
		fi
	done

	# Check required scripts exist
	local required_scripts=("${SCRIPT_DIR}/scripts/lib.sh" "${SCRIPT_DIR}/scripts/install_from_lists.sh" "${SCRIPT_DIR}/scripts/post_config.sh")
	for script in "${required_scripts[@]}"; do
		if [[ ! -f "$script" ]]; then
			error "Required script missing: $script"
			return 1
		fi
	done

	# Check if at least one package list exists
	if ! ls "${SCRIPT_DIR}/lists"/* >/dev/null 2>&1; then
		warn "No package lists found in ${SCRIPT_DIR}/lists"
	fi

	verbose "Environment validation complete"
	return 0
}

if ! validate_environment; then
	error "Environment validation failed. Exiting."
	exit 1
fi

# Run main installation process
info "Starting Arch Linux bootstrap process..."

if (( NO_ACT )); then
	info "=== DRY RUN MODE - No changes will be made ==="
fi

require_arch
require_sudo
pacman_tune

# Update system packages first
info "Updating system packages..."
if (( NO_ACT )); then
	info "[dry-run] Would run: sudo pacman -Syu --noconfirm"
else
	if ! sudo pacman -Syu --noconfirm; then
		error "Failed to update system packages"
		exit 1
	fi
	success "System packages updated successfully"
fi

ensure_base_tools
ensure_yay

# Install from unified lists (auto-detect repo vs AUR per package)
info "Phase 1: Installing packages from lists..."
install_from_lists "${SCRIPT_DIR}/lists"

# Run Docker setup script (copied from omarchy) to ensure daemon config & group membership
info "Phase 2: Setting up Docker..."
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
info "Phase 3: Configuring user environment..."
if ! (( NO_ACT )); then
	post_config
else
	info "Skipping post_config during dry-run."
fi

# SSH setup now always runs (after git config so email is available) unless dry-run
info "Phase 4: Setting up SSH keys..."
if (( NO_ACT )); then
	info "[dry-run] Skipping ssh key setup."
else
	if [[ -f "${SCRIPT_DIR}/scripts/ssh_setup.sh" ]]; then
		source "${SCRIPT_DIR}/scripts/ssh_setup.sh"
		ssh_setup
	else
		warn "ssh_setup.sh missing; skipping SSH key creation"
	fi
fi

# Verify essential commands are available
info "Phase 5: Verifying installation..."
verify_installation

success "All done! Log out/in (or chsh to zsh) to activate shell changes."
