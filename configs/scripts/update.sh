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
tldr --update

# Clean orphaned packages (only if any exist)
echo "🧹 Cleaning orphaned packages..."
orphans=$(pacman -Qdtq 2>/dev/null || true)
if [[ -n "$orphans" ]]; then
    # Filter out packages that don't exist anymore
    valid_orphans=""
    for pkg in $orphans; do
        if pacman -Qi "$pkg" &>/dev/null; then
            valid_orphans="$valid_orphans $pkg"
        fi
    done

    if [[ -n "$valid_orphans" ]]; then
        sudo pacman -Rns $valid_orphans --noconfirm
        echo "✅ Orphaned packages removed"
    else
        echo "✅ No valid orphaned packages to remove"
    fi
else
    echo "✅ No orphaned packages found"
fi

# Clean package cache
echo "🗑️ Cleaning package cache..."
sudo pacman -Sc --noconfirm

echo "✨ System update complete!"
