#!/usr/bin/env bash
# Launch fastfetch with the groups preset and a random image from the images directory.
# Usage: fastfetch.sh [any fastfetch extra args]
set -euo pipefail

# Check if we're in the source directory or installed location
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
if [ -d "$SCRIPT_DIR/images" ] && [ -f "$SCRIPT_DIR/presets/groups.jsonc" ]; then
    # We're in the archinstall source directory
    IMG_DIR="$SCRIPT_DIR/images"
    CONFIG="$SCRIPT_DIR/presets/groups.jsonc"
else
    # We're in the installed location
    IMG_DIR="$HOME/.local/share/fastfetch/images"
    CONFIG="$HOME/.local/share/fastfetch/presets/groups.jsonc"
fi

# Collect candidate image files
mapfile -t IMAGES < <(find "$IMG_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' \))

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "No images found in $IMG_DIR" >&2
  exit 1
fi

# Pick one at random
RANDOM_IMAGE=${IMAGES[RANDOM % ${#IMAGES[@]}]}

# Run fastfetch overriding only the logo source (other logo settings come from config)
exec fastfetch --load-config "$CONFIG" --logo "$RANDOM_IMAGE" "$@"
