
#!/usr/bin/env bash

install_from_list_file() {
  local installer="$1"   # install_repo_pkg | install_aur_pkg
  local file="$2"
  [[ -f "$file" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    # strip comments + trim
    line="${line%%#*}"; line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" ]] && continue
    "$installer" "$line"
  done < "$file"
}

install_from_lists() {
  local dir="$1"

  info "Installing packages listed under ${dir}"
  shopt -s nullglob

  # Repo lists (*.pacman)
  for f in "${dir}"/*.pacman; do
    info "Processing repo list: $(basename "$f")"
    install_from_list_file install_repo_pkg "$f"
  done

  # AUR lists (*.aur)
  for f in "${dir}"/*.aur; do
    info "Processing AUR list: $(basename "$f")"
    install_from_list_file install_aur_pkg "$f"
  done

  shopt -u nullglob
}
