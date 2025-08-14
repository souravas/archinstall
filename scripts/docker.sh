#!/usr/bin/env bash

# Copied from omarchy/install/development/docker.sh
set -euo pipefail

yay -S --noconfirm --needed docker docker-compose docker-buildx

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
