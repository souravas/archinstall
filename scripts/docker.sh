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
	yay -S --noconfirm --needed docker docker-compose docker-buildx
else
	info "Docker already installed, ensuring all components are present..."
	yay -S --noconfirm --needed docker docker-compose docker-buildx
fi

# Limit log size to avoid running out of disk
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json

# Start Docker automatically
sudo systemctl enable docker
sudo systemctl start docker || echo "Warning: failed to start docker service now" >&2

# Give this user privileged Docker access
sudo usermod -aG docker ${USER}

# Prevent Docker from preventing boot for network-online.target
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/no-block-boot.conf <<'EOF'
[Unit]
DefaultDependencies=no
EOF

sudo systemctl daemon-reload

if command -v docker >/dev/null 2>&1; then
	if ! docker info >/dev/null 2>&1; then
		echo "Docker installed but 'docker info' failed (might require relogin for group)." >&2
	else
		echo "Docker daemon responding (docker info succeeded)." >&2
	fi
fi

echo "Docker setup complete. You may need to log out/in for group membership to apply." >&2
