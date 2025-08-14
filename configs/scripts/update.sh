#!/bin/zsh
sudo pacman -Syyu
# sudo pamac update --force-refresh
sudo -u sourav tldr -u
sudo -u sourav yay -Syu --noconfirm
sudo pacman -Rns $(pacman -Qdtq)
