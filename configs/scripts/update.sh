#!/bin/zsh

set -euo pipefail

echo "🔄 Starting system update..."

# Update package databases and system
echo "📦 Updating official packages..."
sudo pacman -Syyu

# Update AUR packages
echo "🔧 Updating AUR packages..."
yay -Syu --noconfirm

# Update tldr database
echo "📖 Updating tldr database..."
tldr -u

# Clean orphaned packages (only if any exist)
echo "🧹 Cleaning orphaned packages..."
orphans=$(pacman -Qdtq 2>/dev/null || true)
if [[ -n "$orphans" ]]; then
    sudo pacman -Rns $orphans --noconfirm
    echo "✅ Orphaned packages removed"
else
    echo "✅ No orphaned packages found"
fi

# Clean package cache
echo "🗑️ Cleaning package cache..."
sudo pacman -Sc --noconfirm

echo "✨ System update complete!"
