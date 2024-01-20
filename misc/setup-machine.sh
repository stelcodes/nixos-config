#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils-full croc

set -eux

ROOT="$1"
TEMPDIR="$(mktemp -d)"
if [ test -z "$ROOT" ]; then
  echo "Please provide a root path of the mounted NixOS installation."
  exit 1
fi
if ! [ test -d "$ROOT/etc/nixos" ]; then
  echo "The provided path doesn't seem to be the root of a NixOS installation"
fi
nixos-generate-config --root "$ROOT" --dir "$TEMPDIR"
croc "$TEMPDIR/hardware-configuration.nix"
