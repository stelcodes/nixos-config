chain="wg-killswitch"

enableKillswitch() {
  cmd="$1"
  "$cmd" --new-chain "$chain" >/dev/null 2>&1 || true
  "$cmd" --insert "$chain" ! --out-interface "$name" --match mark ! --mark "$fwmark" --match addrtype ! --dst-type LOCAL --jump DROP
  while "$cmd" --delete "$chain" 2 >/dev/null 2>&1; do true; done
  "$cmd" --check OUTPUT --jump "$chain" || "$cmd" --insert OUTPUT --jump "$chain"
}

disableKillswitch() {
  cmd="$1"
  "$cmd" --flush "$chain" >/dev/null 2>&1 || true
}

ensureRoot() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Command must be run as root, aborting"
    exit 1
  fi
}

usage() {
  echo "Usage:"
  echo "wg-killswitch enable <interface>"
  echo "wg-killswitch disable"
  echo ""
  echo "Description: Create iptables rules to restrict outgoing traffic to a given wireguard interface"
}

arg1="${1:-""}"
arg2="${2:-""}"
ensureRoot

if [ "$arg1" = "enable" ] && [ -n "$arg2" ]; then
  name="$arg2"
  echo "Enabling killswitch for interface: $name"
  fwmark="$(wg show "$name" fwmark)"
  enableKillswitch iptables
  enableKillswitch ip6tables
  echo "Enabled killswitch successfully"
  exit 0
elif [ "$arg1" = "disable" ]; then
  read -rp 'Disable killswitch? (y/n): '
  if [ "$REPLY" != 'y' ]; then
    echo "Disable subcommand aborted"
    exit 1
  fi
  disableKillswitch iptables
  disableKillswitch ip6tables
  echo "Disabled killswitch successfully"
  exit 0
elif [ "$arg1" = "help" ] || [ "$arg1" = "--help" ]; then
  usage
  exit 0
fi

echo "Invalid arguments, aborting"
echo ""
usage
exit 1
