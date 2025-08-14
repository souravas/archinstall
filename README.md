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
- `lists/01-fonts`
- `lists/02-cli`
- `lists/03-shell`
- `lists/04-terminal`
- `lists/05-dev`
- `lists/06-browsers`
- `lists/07-apps`

You can add/remove packages line-by-line. Lines starting with `#` are ignored.

### Web Applications
Simple webapp installer available as a shell function:
- Prefers **Brave** browser for better privacy
- Available as `webapp-install` command after bootstrap

Install webapps from your terminal:
```bash
# Interactive mode
webapp-install

# Direct installation
webapp-install "GitHub" "https://github.com" "https://icon-url.png"
```

### Dry-run
Preview actions without installing:
```
bash bootstrap.sh --dry-run
```

### Dry-run & Advanced Options
Preview actions without installing:
```
bash bootstrap.sh --dry-run
```

Advanced usage options:
```bash
# Normal installation
./bootstrap.sh

# Dry run to see what would be done
./bootstrap.sh --dry-run

# Verbose output for debugging
./bootstrap.sh --verbose

# Dry run with verbose output
./bootstrap.sh --dry-run --verbose

# Show help
./bootstrap.sh --help
```

### Development Environment Setup
The bootstrap automatically sets up a Node.js development environment using `mise` (instead of nvm). After installation:

- **Node.js LTS** is installed via `mise`
- **mise** is configured for your shell
- **Python** is available from the system (with `uv` for package management)

You can also manually setup development environments:
```bash
# Install/reinstall Node.js LTS
./scripts/dev_env.sh node

# Or just run dev_env.sh (defaults to node)
./scripts/dev_env.sh
```

## What gets configured
- **Ghostty** config at `~/.config/ghostty/config` (catppuccin-mocha, dark, 0.9 opacity)
- **Starship** theme preset written to `~/.config/starship.toml`
- **Oh My Zsh** with plugins: `git`, `git-prompt`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `python`
- Your **.zshrc** (from this repo) copied to `~` (existing one is backed up)
- **Git** globals (name, email, editor)
- **Fonts** are refreshed with `fc-cache -fv`
- **Node.js LTS** via `mise` for development
- **Development tools** including VS Code, Neovim, and various CLI tools

## Key Features

1. **Safety**: Added dry-run validation and environment checks
2. **Debugging**: Verbose mode for troubleshooting
3. **Reliability**: Better error handling and recovery
4. **User Experience**: Clear progress phases and better messaging
5. **Maintainability**: Cleaner code structure and documentation
6. **Modern tooling**: Uses `mise` instead of `nvm` for better Node.js management
