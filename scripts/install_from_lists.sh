
#!/usr/bin/env bash

install_from_list_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0

  verbose "Processing package list: $file"

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove comments and trim whitespace
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # Skip empty lines
    [[ -n "$line" ]] || continue

    verbose "Processing package: $line"

    # Fast path: check if it's an official repo package first
    if pacman -Si -- "$line" &>/dev/null; then
      install_repo_pkg "$line"
    else
      # Fallback to AUR (handles both source and binary packages)
      install_aur_pkg "$line"
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
