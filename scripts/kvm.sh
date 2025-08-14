#!/usr/bin/env bash

# KVM/QEMU setup script - Install KVM/QEMU + libvirt + virt-manager on Arch Linux
# Safe around iptables{,-nft,-legacy} conflicts.
set -euo pipefail

# Source lib functions if available for consistent messaging
if declare -F info >/dev/null 2>&1; then
	: # Functions already available
elif [[ -f "$(dirname "${BASH_SOURCE[0]}")/lib.sh" ]]; then
	source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
else
	# Fallback functions
	info() { echo "[INFO] $*"; }
	warn() { echo "[WARN] $*" >&2; }
	error() { echo "[ERROR] $*" >&2; }
	success() { echo "[SUCCESS] $*"; }
fi

# --- Helpers ---------------------------------------------------------------
is_cmd() { command -v "$1" >/dev/null 2>&1; }
as_root() { if [ "$(id -u)" -ne 0 ]; then sudo "$@"; else "$@"; fi; }
have_pkg() { pacman -Qi "$1" &>/dev/null; }

# --- Sanity checks ---------------------------------------------------------
if ! is_cmd pacman; then
  error "This script is for Arch Linux (needs pacman). Aborting."
  exit 1
fi

info "Setting up KVM/QEMU virtualization..."

TARGET_USER="${SUDO_USER:-$USER}"

# CPU virtualization flags check
if ! grep -Eq '(vmx|svm)' /proc/cpuinfo; then
  warn "CPU virtualization extensions (vmx/svm) not detected."
  warn "Enable virtualization in BIOS/UEFI for best performance."
fi

# --- Package selection (conflict-safe) ------------------------------------
# Base VM stack
PKGS=(
  qemu-desktop
  libvirt
  virt-manager
  virt-install
  edk2-ovmf
  swtpm
  dnsmasq
  virt-viewer
)

# iptables provider handling:
# If you already have *any* provider (iptables, iptables-nft, or iptables-legacy), don't install another.
if have_pkg iptables || have_pkg iptables-nft || have_pkg iptables-legacy; then
  info "Detected existing iptables provider; not installing a new one."
else
  # Default to nft-based provider on fresh systems
  PKGS+=(iptables-nft)
fi

info "Updating system and installing virtualization packages..."
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would install: ${PKGS[*]}"
else
	as_root pacman -Syu --needed --noconfirm "${PKGS[@]}"
fi

# --- Load KVM modules and persist -----------------------------------------
info "Loading KVM kernel modules..."
CPU_VENDOR="$(lscpu | awk -F: '/Vendor ID/{print $2}' | xargs || true)"
if (( ${NO_ACT:-0} )); then
	if grep -q "GenuineIntel" <<<"$CPU_VENDOR"; then
		info "[dry-run] Would load kvm and kvm_intel modules"
		info "[dry-run] Would create /etc/modules-load.d/kvm.conf with kvm and kvm_intel"
	elif grep -q "AuthenticAMD" <<<"$CPU_VENDOR"; then
		info "[dry-run] Would load kvm and kvm_amd modules"
		info "[dry-run] Would create /etc/modules-load.d/kvm.conf with kvm and kvm_amd"
	else
		info "[dry-run] Would load kvm module"
		info "[dry-run] Would create /etc/modules-load.d/kvm.conf with kvm"
	fi
else
	if grep -q "GenuineIntel" <<<"$CPU_VENDOR"; then
		as_root modprobe kvm kvm_intel || true
		as_root sh -c 'printf "%s\n" kvm kvm_intel > /etc/modules-load.d/kvm.conf'
	elif grep -q "AuthenticAMD" <<<"$CPU_VENDOR"; then
		as_root modprobe kvm kvm_amd || true
		as_root sh -c 'printf "%s\n" kvm kvm_amd > /etc/modules-load.d/kvm.conf'
	else
		as_root modprobe kvm || true
		as_root sh -c 'printf "%s\n" kvm > /etc/modules-load.d/kvm.conf'
	fi
fi

# --- Enable libvirt (socket activation) -----------------------------------
info "Enabling libvirt (socket-activated)..."
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would enable and start libvirtd.socket"
	info "[dry-run] Would start libvirtd.service if present"
else
	as_root systemctl enable --now libvirtd.socket
	# Start the traditional service if present
	if systemctl list-unit-files | grep -q '^libvirtd.service'; then
		as_root systemctl start libvirtd.service || true
	fi
fi

# --- Default NAT network via dnsmasq --------------------------------------
info "Ensuring libvirt 'default' NAT network exists and is active..."
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would configure libvirt default NAT network"
	info "[dry-run] Would set network to autostart and start it"
else
	if ! sudo virsh net-info default >/dev/null 2>&1; then
		if [ -f /usr/share/libvirt/networks/default.xml ]; then
			as_root virsh net-define /usr/share/libvirt/networks/default.xml
		fi
	fi
	as_root virsh net-autostart default || true
	as_root virsh net-start default || true
fi

# --- Permissions -----------------------------------------------------------
info "Adding user '$TARGET_USER' to kvm and libvirt groups..."
if (( ${NO_ACT:-0} )); then
	info "[dry-run] Would add user '$TARGET_USER' to kvm and libvirt groups"
else
	as_root gpasswd -a "$TARGET_USER" kvm || true
	as_root gpasswd -a "$TARGET_USER" libvirt || true
fi

# --- Quick host validation (informational) ---------------------------------
if is_cmd virt-host-validate; then
	info "Running virt-host-validate (informational)..."
	if ! (( ${NO_ACT:-0} )); then
		virt-host-validate qemu || true
	else
		info "[dry-run] Would run virt-host-validate qemu"
	fi
fi

success "KVM/QEMU setup complete!"
success "Reboot or log out/in so group changes take effect."
success "Launch the GUI with: virt-manager"
success "- For UEFI guests, pick an OVMF firmware (edk2-ovmf)."
success "- For Windows 11, add a TPM 2.0 device (swtpm)."
