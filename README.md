# Arch KDE Bootstrap (Sourav Edition)

This kit installs your preferred tools on a fresh **Arch Linux KDE** VM using **pacman** (for official repos) and **yay** (for AUR). Package names are grouped by category (one file per category) and you can freely mix repo + AUR entries; the script auto-detects which backend to use per package.

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
  - Install everything from the lists (each list may contain both repo and AUR packages)
  - Configure Ghostty, Starship (catppuccin-powerline), Oh My Zsh plugins, fonts
  - Apply your provided `.zshrc`
  - Apply your global git config
  - Create `~/.scripts/update.sh` and an alias `u` to run it

> Note: Lists are unified now (no `.pacman` / `.aur` split). For each package the script first checks if it's in the official repos (fast pacman path) and otherwise installs it via `yay` from AUR.

## Lists
Current category files (repo + AUR mixed):
- `lists/fonts`
- `lists/browsers`
- `lists/dev`
- `lists/terminal`
- `lists/cli`
- `lists/shell`

You can add/remove packages line-by-line. Lines starting with `#` are ignored.

### Dry-run
Preview actions without installing:
```
bash bootstrap.sh --dry-run
```
Shows which pacman vs yay commands would run and performs detection only.

## What gets configured
- **Ghostty** config at `~/.config/ghostty/config` (catppuccin-mocha, dark, 0.9 opacity)
- **Starship** theme preset written to `~/.config/starship.toml`
- **Oh My Zsh** with plugins: `git`, `git-prompt`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `python`
- Your **.zshrc** (from this repo) copied to `~` (existing one is backed up)
- **Git** globals (name, email, editor)
- **Fonts** are refreshed with `fc-cache -fv`
