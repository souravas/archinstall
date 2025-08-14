# Arch KDE Bootstrap (Sourav Edition)

This kit installs your preferred tools on a fresh **Arch Linux KDE** VM using **pacman** for official repos and **yay** for AUR. Packages are split by category into separate files so you can edit them before running.

## TL;DR
```bash
# 1) Extract this zip and cd into the folder
cd arch-kde-bootstrap

# 2) Run the bootstrap (no need to run as root; it will sudo when needed)
bash bootstrap.sh
```

- Edit the package lists in `lists/` before running if you want.
- The script will:
  - Ensure pacman is tuned (color + parallel downloads)
  - Install `yay` (AUR helper) if missing
  - Install everything from the lists (`*.pacman` with pacman, `*.aur` with yay)
  - Configure Ghostty, Starship (catppuccin-powerline), Oh My Zsh plugins, fonts
  - Apply your provided `.zshrc`
  - Apply your global git config
  - Create `~/.scripts/update.sh` and an alias `u` to run it

> Note: `yay` can install **both** repo and AUR packages, but here we keep explicit control by placing repo packages in `*.pacman` and AUR ones in `*.aur` lists.

## Lists
- `lists/fonts.pacman` and `lists/fonts.aur`
- `lists/browsers.aur`
- `lists/dev.aur`
- `lists/terminal.pacman`
- `lists/cli.pacman`
- `lists/shell.pacman`
- `lists/shell.aur`

You can add/remove packages line-by-line. Lines starting with `#` are ignored.

## What gets configured
- **Ghostty** config at `~/.config/ghostty/config` (catppuccin-mocha, dark, 0.9 opacity)
- **Starship** theme preset written to `~/.config/starship.toml`
- **Oh My Zsh** with plugins: `git`, `git-prompt`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `python`
- Your **.zshrc** (from this repo) copied to `~` (existing one is backed up)
- **Git** globals (name, email, editor)
- **Fonts** are refreshed with `fc-cache -fv`

## Optional/Notes
- Your `.zshrc` aliases `docker=podman`. If you actually want Docker, remove that alias; otherwise we install `podman` + `podman-docker` so the alias works.
- The `bright()` function in `.zshrc` uses `ddccontrol` which is in AUR and may not work on all monitors. If you don't need it, remove that function.

## Inspired by
- The structure borrows ideas from Basecamp’s **Omarchy** (category lists, sensible defaults, idempotent scripts).
