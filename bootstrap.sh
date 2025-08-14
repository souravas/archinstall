
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/scripts/lib.sh"
source "${SCRIPT_DIR}/scripts/install_from_lists.sh"
source "${SCRIPT_DIR}/scripts/post_config.sh"

require_arch
require_sudo
pacman_tune
ensure_base_tools
ensure_yay

# Install from lists (repo vs AUR kept separate for speed and clarity)
install_from_lists "${SCRIPT_DIR}/lists"

# Run post-install user configs (zsh, starship, ghostty, git, etc.)
post_config

success "All done! Log out/in (or chsh to zsh) to activate shell changes."
