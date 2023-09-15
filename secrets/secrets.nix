let
  users = { };
  systems = {
    meshify = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnPEH3EdHpXZxp4yfD2/psm1m8dbHSGnQ95NLPf6S5g";
  };
in
{
  # For all systems use `builtins.attrValues systems`

  "meshify/wg/pvpn-fast/private-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-fast/public-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-fast/endpoint.age".publicKeys = [ systems.meshify ];

  "meshify/wg/pvpn-secure/private-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-secure/public-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-secure/endpoint.age".publicKeys = [ systems.meshify ];
}
