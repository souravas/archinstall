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

# Function to detect if we're in a VM or if image display might not work
is_vm_or_limited_display() {
    # Check for common VM indicators
    if [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_TTY:-}" ]]; then
        return 0  # SSH session
    fi

    # Check for VM-specific strings in dmesg/system info
    if grep -qi "virtual\|vmware\|qemu\|kvm\|virtualbox\|xen" /proc/cpuinfo 2>/dev/null; then
        return 0  # Virtual machine detected
    fi

    # Check if terminal supports images (basic check)
    if [[ "$TERM" == "linux" ]] || [[ "$TERM" == "screen"* ]]; then
        return 0  # Terminal likely doesn't support images
    fi

    return 1  # Probably can display images
}

# Try image logo first, fall back to ASCII if needed
if is_vm_or_limited_display; then
    # Use ASCII logo in VMs or limited environments
    exec fastfetch --load-config "$CONFIG" --logo arch "$@"
else
    # Collect candidate image files
    mapfile -t IMAGES < <(find "$IMG_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' \))

    if [[ ${#IMAGES[@]} -eq 0 ]]; then
        # Fall back to ASCII logo if no images found
        exec fastfetch --load-config "$CONFIG" --logo arch "$@"
    fi

    # Pick one at random
    RANDOM_IMAGE=${IMAGES[RANDOM % ${#IMAGES[@]}]}

    # Try to run with image logo, fall back to ASCII on failure
    if ! fastfetch --load-config "$CONFIG" --logo "$RANDOM_IMAGE" "$@" 2>/dev/null; then
        exec fastfetch --load-config "$CONFIG" --logo arch "$@"
    fi
fi
