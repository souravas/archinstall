#!/bin/bash
# Install Oh My Zsh plugins
# This script is now mainly for reference since zsh-autosuggestions and zsh-syntax-highlighting
# are installed via package manager in the 'shell' list

echo "Oh My Zsh plugin installation info..."

# Check if Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Error: Oh My Zsh is not installed. Please install it first."
    echo "Run: sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    exit 1
fi

echo "✅ Oh My Zsh is installed"
echo ""
echo "📦 The following plugins are installed via package manager (in 'shell' list):"
echo "  - zsh-autosuggestions"
echo "  - zsh-syntax-highlighting"
echo ""
echo "🔧 These are automatically sourced in omz.zsh configuration"
echo "ℹ️  No manual installation needed for these plugins!"
