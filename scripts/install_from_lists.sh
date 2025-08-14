
#!/usr/bin/env bash

install_from_list_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"; line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}";
    [[ -z "$line" ]] && continue
    # Fast path: if it's an official repo pkg, use pacman directly (faster, no AUR metadata)
    if pacman -Si -- "$line" &>/dev/null; then
      install_repo_pkg "$line"
    else
      install_aur_pkg "$line"  # falls back to yay (handles both build + bin AUR)
    fi
  done < "$file"
}

install_from_lists() {
  local dir="$1"
  if (( NO_ACT )); then
    info "[dry-run] Resolving packages from unified lists in ${dir} (mixed repo + AUR)"
  else
    info "Installing packages from unified lists in ${dir} (mixed repo + AUR)"
  fi
  shopt -s nullglob
  for f in "${dir}"/*; do
    [[ -f "$f" ]] || continue
    info "Processing list: $(basename "$f")"
    install_from_list_file "$f"
  done
  shopt -u nullglob
}
