#!/usr/bin/env bash

set -euxo pipefail

STATUS_FILE=/tmp/nixos-rebuild.status
LOG_FILE=/tmp/nixos-rebuild.log

setup() {
  echo "" > $STATUS_FILE
}

succeed() {
  echo "" > $STATUS_FILE
  mpv $SUCCESS_ALERT || true
}

fail() {
  echo "" > $STATUS_FILE
  exit 1
}

ensure_network() {
  ping -c 1 -W 5 8.8.8.8 &> /dev/null || {
    echo 'ERROR: Network not up' | tee $LOG_FILE
    mpv $FAILURE_ALERT || true
    fail
  }
}

rebuild_config() {
  {
    doas nixos-rebuild switch --flake "$HOME/nixos-config#" 2>&1 | tee $LOG_FILE && succeed
  } || {
    echo "ERROR: Config rebuild failed"
    mpv $FAILURE_ALERT || true
    fail
  }
}

trap "fail" SIGINT SIGTERM SIGKILL ERR

setup
rebuild_config
