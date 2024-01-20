#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils-full croc

set -eu

ROOT="$1"
if [ test -z "$ROOT" ]; then
  echo "Please provide a root path of the mounted NixOS installation."
  exit 1
fi
if ! [ test -d "$ROOT/etc/nixos" ]; then
  echo "The provided path doesn't seem to be the root of a NixOS installation"
fi

echo "Sending new hardware-configuration.nix..."
TEMPDIR="$(mktemp -d)"
nixos-generate-config --root "$ROOT" --dir "$TEMPDIR"
croc "$TEMPDIR/hardware-configuration.nix"

echo "Sending system ssh public key..."
SYSTEM_SSH_KEY="$ROOT/etc/ssh/ssh_host_ed25519_key.pub"
if ! [ test -f "$SYSTEM_SSH_KEY" ]; then
  echo "Can't locate the system ssh key"
fi
croc "$SYSTEM_SSH_KEY"

echo "Remember to rekey necessary secrets:"
echo "cd ~/nixos-config/secrets"
echo "agenix --rekey"
