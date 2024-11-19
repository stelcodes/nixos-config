#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils-full croc git

set -eu

CROC_DIR="$(mktemp -d)"
HOSTNAME="$1"
ROOT="$2"
if [ -z "$HOSTNAME" ] || [ ! -d "$ROOT" ]; then
  echo "USAGE:"
  echo "setup-machine.sh <hostname> <mounted_root_dir>"
  exit 1
else
  echo "Starting setup-machine"
  echo "HOSTNAME: $HOSTNAME"
  echo "ROOT: $ROOT"
fi


# echo "Running nixos-generate-config"
# nixos-generate-config --root "$ROOT" --dir "$CROC_DIR"
echo "Copying new system's config"
CONFIG_DIR="$ROOT/etc/nixos"
if [ -d "$CONFIG_DIR" ]; then
  cp "$CONFIG_DIR"/* "$CROC_DIR"
else
  echo "Can't locate the system config"
fi

echo "Copying new system's ssh public key"
SYSTEM_SSH_KEY="$ROOT/etc/ssh/ssh_host_ed25519_key.pub"
if [ -f "$SYSTEM_SSH_KEY" ]; then
  cp "$SYSTEM_SSH_KEY" "$CROC_DIR"
else
  echo "Can't locate the system ssh key"
fi

echo "Files to be sent:"
ls -l "$CROC_DIR"
echo
read -rp "Send files? (Y/n):"

if [ -z "$REPLY" ] || [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
  croc "$CROC_DIR"
fi

echo "1. Add machine configuration to host directory"
echo "2. Add machine ssh key to secrets.nix"
echo "3. Rekey secrets: cd secrets && agenix --rekey"
echo "4. Commit and push changes"

read -rp "Done committing and pushing changes? (Y/n):"
if [ -z "$REPLY" ] || [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
  echo "Starting secondary installation"
  if ! install-nixos --no-channel-copy --root "$ROOT" --flake "github:stelcodes/nixos-config#$HOSTNAME"; then
    echo "Secondary installation failed"
  else
    echo "Secondary installation succeeded"
    echo "Cloning nixos-config to new machine"
    if ! git clone https://github.com/stelcodes/nixos-config "$ROOT/home/stel/.config/nixflake"; then
      echo "Could not clone config to new machine"
    fi
  fi
fi
