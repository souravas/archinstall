#!/usr/bin/env bash
set -euo pipefail
echo "[*] Syncing and updating pacman packages..."
sudo pacman -Syu --noconfirm
if command -v yay >/dev/null 2>&1; then
  echo "[*] Updating AUR packages with yay..."
  yay -Syu --devel --timeupdate --noconfirm
fi
echo "[*] Cleaning package caches (optional)..."
paccache -r || true
echo "[✓] System updated."
