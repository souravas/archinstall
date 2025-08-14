#!/usr/bin/env bash

# Docker setup script - copied from omarchy/install/development/docker.sh
set -euo pipefail

# Source lib functions if available for consistent messaging
if declare -F info >/dev/null 2>&1; then
	: # Functions already available
elif [[ -f "$(dirname "${BASH_SOURCE[0]}")/lib.sh" ]]; then
	source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
else
	# Fallback functions
	info() { echo "[INFO] $*"; }
	warn() { echo "[WARN] $*" >&2; }
	error() { echo "[ERROR] $*" >&2; }
	success() { echo "[SUCCESS] $*"; }
fi

info "Setting up Docker..."

# Install Docker packages if not already present
if ! command -v docker >/dev/null 2>&1; then
	info "Installing Docker packages..."
	if (( ${NO_ACT:-0} )); then
		info "[dry-run] Would install: docker docker-compose docker-buildx"
	else
		yay -S --noconfirm --needed docker docker-compose docker-buildx
	fi
else
	info "Docker already installed, ensuring all components are present..."
	if (( ${NO_ACT:-0} )); then
		info "[dry-run] Would ensure installed: docker docker-compose docker-buildx"
	else
		yay -S --noconfirm --needed docker docker-compose docker-buildx
	fi
fi

# Limit log size to avoid running out of disk
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would configure Docker daemon.json for log rotation"
else
	sudo mkdir -p /etc/docker
	echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json >/dev/null
fi

# Start Docker automatically
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would enable Docker service"
else
	sudo systemctl enable docker
fi

# Give this user privileged Docker access
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would add user ${USER} to docker group"
else
	sudo usermod -aG docker ${USER}
fi

# Prevent Docker from preventing boot for network-online.target
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would configure Docker service to not block boot"
else
	sudo mkdir -p /etc/systemd/system/docker.service.d
	sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF

	sudo systemctl daemon-reload
fi

success "Docker setup complete. Docker will start automatically on next boot."
success "You may need to log out/in for group membership to apply."
