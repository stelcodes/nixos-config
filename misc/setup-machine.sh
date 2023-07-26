#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git neovim fish

set -eux

HOST_NAME="$1"
CONFIG_DIR="$HOME/nixos-config"
HOST_DIR="$CONFIG_DIR/hosts/$HOST_NAME"

if test ! "$HOST_NAME"; then
  echo "Hostname is required"
  exit 1
fi

git clone https://github.com/stelcodes/nixos-config "$CONFIG_DIR"
mkdir -p "$HOST_DIR"
cp -a /etc/nixos/* "$HOST_DIR"
nvim "$CONFIG_DIR"

cd "$CONFIG_DIR"
git add "$HOST_DIR"

nixos-rebuild switch --flake "$CONFIG_DIR#$HOST_NAME"
